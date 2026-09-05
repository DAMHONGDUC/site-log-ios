# 02 — Capture pipeline

Module: `Packages/Capture`

Đây là một trong ba vùng **tự viết, không dùng SDK**. `UIImagePickerController` và
`PhotosPicker` bị loại — không phải vì chúng tệ, mà vì chúng che mất đúng phần cần chứng minh:
điều khiển `AVCaptureSession` trực tiếp.

## 1. Mục tiêu

Một `AVCaptureSession` duy nhất phục vụ cả ảnh, video và audio, chuyển qua lại không dựng lại
session, và mỗi file ghi xong đều có `sha256` trước khi vào DB.

## 2. Phạm vi

**Trong phạm vi**

1. Chụp ảnh (`AVCapturePhotoOutput`), quay video + audio (`AVAssetWriter`), ghi âm riêng.
2. Torch, zoom (pinch + nút), đổi camera trước/sau, đếm giờ khi quay.
3. Chụp liên tiếp không rời màn hình — thanh thumbnail cuộn ngang ở dưới.
4. Gắn GPS + `deviceModel` + `capturedAt` vào metadata.
5. Hash SHA-256 ngay sau khi file đóng.
6. Pre-record buffer 30 giây (giai đoạn sau — xem §7).

**Ngoài phạm vi**

1. Chỉnh sửa ảnh (crop, filter). `Capture` bất biến.
2. Chọn ảnh từ thư viện — mọi ảnh phải sinh ra trong app để hash có ý nghĩa.

## 3. Kiến trúc session

```
AVCaptureSession
├── inputs:  AVCaptureDeviceInput(video: back/front)
│            AVCaptureDeviceInput(audio: mic)
├── outputs: AVCapturePhotoOutput          → ảnh
│            AVCaptureVideoDataOutput      → sample buffer → AVAssetWriter
│            AVCaptureAudioDataOutput      → sample buffer → AVAssetWriter
└── preview: AVCaptureVideoPreviewLayer (UIViewRepresentable)
```

Dùng `AVCaptureVideoDataOutput` + `AVAssetWriter` thay vì `AVCaptureMovieFileOutput`, vì:

1. `AVAssetWriter` là điều kiện bắt buộc cho pre-record buffer (§7).
2. Kiểm soát được bitrate/codec, quan trọng khi mỗi đợt ra vài GB phải upload qua 3G.

Đánh đổi: phải tự quản lý session state, timestamp và rotation. Chấp nhận — đó là phần cần
chứng minh.

### Quy tắc queue

| Việc | Chạy ở đâu |
|---|---|
| `session.startRunning()` / `stopRunning()` / mọi `configuration` | `sessionQueue` (serial, `.userInitiated`) |
| Nhận sample buffer | `videoDataQueue` / `audioDataQueue` (serial) |
| `AVAssetWriter` append | `writerQueue` (serial) |
| Cập nhật UI (thumbnail, timer, state) | `@MainActor` |

**Không bao giờ** gọi `startRunning()` trên main thread — nó block 300–800ms và làm app khựng
lúc mở camera, lỗi kinh điển nhất của pipeline tự viết.

### State machine

```
idle → configuring → ready → capturingPhoto → ready
                       ↓                        ↑
                   recording ──────────────────┘
                       ↓
                   finalizing (writer.finishWriting + hash)
```

`interrupted` là nhánh riêng: cuộc gọi đến, app vào background, camera bị app khác chiếm.
Nghe `AVCaptureSessionWasInterrupted` / `InterruptionEnded`, và nếu đang `recording` thì
**finalize file hiện tại chứ không vứt**. Người dùng thà có 8 giây video còn hơn mất cả clip.

## 4. Metadata

Gắn tại thời điểm ghi, không suy ra sau:

| Field | Nguồn | Khi thiếu |
|---|---|---|
| `capturedAt` | `Date()` lúc `didFinishProcessingPhoto` | không bao giờ thiếu |
| `latitude/longitude` | `CLLocationManager`, cache location gần nhất | **`nil`, không chặn capture** |
| `horizontalAccuracy` | cùng nguồn | `nil` |
| `deviceModel` | `utsname` | |
| `sha256` | tính từ file sau khi đóng | không bao giờ thiếu |

**GPS không bao giờ được chặn capture.** Hầm gửi xe không có GPS, và đó chính là nơi người
dùng đang đứng. `CLLocationManager` chạy `desiredAccuracy = .nearestTenMeters`, giữ location
gần nhất trong bộ nhớ; quá 2 phút thì coi là stale và ghi `nil` thay vì ghi số sai.

## 5. Hash

```swift
func sha256(ofFileAt url: URL) throws -> String {
    let handle = try FileHandle(forReadingFrom: url)
    defer { try? handle.close() }
    var hasher = SHA256()
    while let chunk = try handle.read(upToCount: HashConstants.streamingChunkBytes),
          chunk.isEmpty == false {
        hasher.update(data: chunk)
    }
    return hasher.finalize().map { String(format: "%02x", $0) }.joined()
}
```

Đọc theo chunk, **không** `Data(contentsOf:)` — một video 4K 3 phút là ~1.5GB và nạp cả vào
RAM sẽ bị jetsam kill.

Hash chạy trên `hashQueue` (`.utility`), và `Capture` chỉ được ghi vào DB **sau khi** có hash.
Nếu app chết giữa chừng, file mồ côi trên disk sẽ bị dọn lúc khởi động (xem
[09-diagnostics.md](09-diagnostics.md)).

## 6. Lưu file

```
<AppSupport>/media/<projectID>/<sessionID>/<captureID>.<ext>
```

1. Đặt `FileProtectionType.completeUnlessOpen` cho từng file — đây là at-rest encryption thật
   sự, hardware-backed. Chi tiết và lý do không tự AES-GCM ở đây: [07-security.md](07-security.md).
2. Thư mục `media/` có `isExcludedFromBackup = true`. Vài GB media không nên đẩy lên iCloud
   backup của người dùng; nguồn sự thật là R2.
3. DB lưu **path tương đối**, resolve tại runtime.

## 7. Pre-record buffer (giai đoạn sau)

Luôn giữ 30 giây gần nhất để khi bấm record thì 30 giây **trước đó** cũng được lưu. Đây là cách
body cam thật hoạt động và là phần hiếm thấy trong portfolio.

**Không giữ raw sample buffer trong RAM.** 30 giây video 4K chưa nén là nhiều GB — máy sẽ bị
kill trước khi người dùng bấm nút. Cách đúng:

1. `AVAssetWriter` ghi **segment ngắn 3 giây** liên tục ra `<Caches>/prebuffer/`.
2. Giữ vòng 11 segment gần nhất (33s), xoá segment cũ nhất mỗi lần đóng segment mới.
3. Bấm record → dừng vòng, ghi tiếp vào segment mới, rồi nối toàn bộ bằng
   `AVMutableComposition` + `AVAssetExportSession`.
4. Không bấm record trong 30s → segment cũ tự rụng, không tốn gì thêm.

Chi phí: ghi liên tục làm nóng máy và tốn pin. Vì vậy pre-record là **toggle tắt mặc định**,
và tự tắt khi pin < 20%.

Cắt trước tiên nếu hụt thời gian.

## 8. Constants

```swift
enum CaptureConstants {
    static let photoQualityPrioritization: AVCapturePhotoOutput.QualityPrioritization = .balanced
    static let videoBitrate: Int = 8_000_000
    static let maxVideoDuration: TimeInterval = 600
    static let locationStaleAfter: TimeInterval = 120
}

enum PreRecordConstants {
    static let segmentDuration: TimeInterval = 3
    static let segmentCount: Int = 11
    static let minBatteryLevel: Float = 0.20
}

enum HashConstants {
    static let streamingChunkBytes: Int = 1_048_576
}
```

## 9. Rủi ro đã biết

1. **Hết dung lượng giữa lúc quay.** Check free space trước khi bắt đầu; dưới 500MB thì chặn
   quay video và nói rõ còn bao nhiêu.
2. **Nhiệt độ.** `ProcessInfo.thermalState == .serious` → hạ bitrate; `.critical` → dừng quay
   và báo, đừng để OS tự kill.
3. **Quyền bị từ chối.** Camera/mic/location xử lý riêng từng cái, không gộp một alert. Từ chối
   location vẫn chụp được — chỉ mất toạ độ.
4. **Rotation.** Preview layer và `AVAssetWriter` transform phải khớp, nếu không video xuất ra
   bị xoay 90° và chỉ phát hiện khi mở PDF.

## 10. Definition of done

1. Chụp 50 ảnh liên tiếp không rời màn hình, RAM không leo, không rớt frame preview.
2. Quay 3 phút 1080p → file phát được, hash khớp khi tính lại, metadata đủ.
3. Nhận cuộc gọi giữa lúc quay → file được finalize, không mất, `uploadState = .pending`.
4. Chế độ máy bay + từ chối location → capture vẫn xong, `latitude == nil`.
5. Zero warning.

## 11. Test

| Test | Loại |
|---|---|
| `sha256(ofFileAt:)` khớp vector chuẩn, và khớp `shasum -a 256` trên file 200MB | unit |
| State machine từ chối `startRecording` khi đang `capturingPhoto` | unit, không cần camera |
| `interrupted` khi đang `recording` → gọi finalize đúng một lần | unit, mock session |
| Location quá `locationStaleAfter` → metadata ghi `nil` | unit, inject clock |
| Ring buffer giữ đúng `segmentCount`, xoá đúng segment cũ nhất | unit, fake filesystem |
| Quay + finalize + hash trên máy thật | manual, checklist trong PR |

State machine và ring buffer test **không được cần camera thật** — inject protocol
`CaptureSessionControlling` để chạy được trên CI.
