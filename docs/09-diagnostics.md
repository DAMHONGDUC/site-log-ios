# 09 — Diagnostics & observability

Module: `App/Features/Diagnostics`

Một app offline-first với upload nền là app mà **người dùng không thấy được chuyện gì đang xảy
ra**. Diagnostics không phải màn hình phụ — nó là cách duy nhất để trả lời "ảnh của tôi đâu?"
mà không cần cắm máy vào Xcode.

## 1. Mục tiêu

1. Người dùng tự trả lời được: đã upload bao nhiêu, còn bao nhiêu, cái gì đang kẹt và vì sao.
2. Dev nhận được **một file** từ người dùng là đủ để chẩn đoán, không cần dựng lại hiện trường.
3. Dọn được rác trên disk mà không xoá nhầm thứ chưa upload.

## 2. Phạm vi

**Trong phạm vi**

1. Màn hình trạng thái upload: tổng quan + danh sách job đang kẹt kèm lý do cụ thể.
2. Thống kê dung lượng theo project, tách rõ **đã sync** / **chưa sync**.
3. Dọn dẹp có kiểm soát: xoá local file đã `synced`, xoá temp part mồ côi, xoá prebuffer.
4. Kiểm tra toàn vẹn: verify hash mẫu, verify audit chain, tìm capture mất file.
5. Export gói chẩn đoán (log + state, **đã redact**).
6. Cờ trạng thái hệ thống: quyền, mạng, dung lượng, nhiệt, pin.

**Ngoài phạm vi**

1. Dashboard analytics cho quản lý (v2).
2. Chỉnh sửa trực tiếp DB từ UI. Cám dỗ lớn, hậu quả lớn hơn.

## 3. Màn hình trạng thái upload

Điều quan trọng nhất là **nói đúng sự thật**, không phải nói cho êm tai:

```
┌─────────────────────────────────────┐
│ Đợt 05/09 — Chung cư Ánh Dương      │
│ ████████████░░░░  187/243 file      │
│ 1.8 GB / 2.4 GB · còn ~6 phút       │
│                                     │
│ ⚠ 4 file đang chờ                   │
│   • Chờ WiFi (3)                    │
│   • Chờ cấp lại đường tải (1)       │
│ ✕ 2 file lỗi — [Thử lại]            │
└─────────────────────────────────────┘
```

1. Phân biệt rõ **chờ** và **lỗi**. `waitingForNetwork` và `waitingForURL` không phải lỗi và
   không được hiện màu đỏ — chúng là trạng thái bình thường của app này
   ([04-upload-engine.md](04-upload-engine.md) §6).
2. Mỗi job kẹt hiện **lý do bằng tiếng người**, không hiện enum: "Chờ WiFi" chứ không
   "waitingForNetwork".
3. Nếu OS đang giữ task ở chế độ discretionary, nói thật: "Sẽ tải khi máy rảnh" — đừng hứa cái
   không kiểm soát được ([04-upload-engine.md](04-upload-engine.md) §4.2).
4. Ước tính thời gian tính từ throughput 60 giây gần nhất, không tính từ trung bình toàn phiên.
5. Khi kênh [realtime](10-realtime-progress.md) đang mở, trạng thái cập nhật do server push;
   khi nó đóng, màn hình vẫn đúng — chỉ chậm hơn. Không hiện lỗi vì WebSocket không nối được.

## 4. Kiểm tra toàn vẹn

Chạy theo yêu cầu, hiện tiến độ, huỷ được:

| Kiểm tra | Phát hiện |
|---|---|
| Capture có record nhưng thiếu file trên disk | mất media |
| File trong `media/` không có record | file mồ côi (app chết sau ghi, trước khi lưu DB) |
| Hash tính lại ≠ `sha256` đã lưu | file hỏng hoặc bị thay |
| Audit chain HMAC | log bị sửa ([07-security.md](07-security.md)) |
| Temp part không thuộc job nào | rác upload |
| `uploading` nhưng không có task tương ứng | job treo, cần reset về `pending` |

Verify hash toàn bộ vài GB là chậm. Mặc định verify **mẫu ngẫu nhiên** `sampleSize` file; có nút
"kiểm tra toàn bộ" chạy nền.

## 5. Dọn dẹp

Nút xoá trong app này nguy hiểm hơn bình thường — media là bằng chứng và không có bản sao nào
khác cho tới khi `synced`.

1. **Chỉ xoá file `synced`.** File `pending` / `failed` không bao giờ nằm trong phạm vi dọn dẹp
   tự động, kể cả khi hết dung lượng.
2. Hiện con số cụ thể trước khi xoá: "Xoá 156 file đã tải lên, giải phóng 1.4 GB. 12 file chưa
   tải lên sẽ được giữ lại."
3. Xoá temp part mồ côi và prebuffer thì không cần hỏi — chúng luôn là rác.
4. Mỗi lần dọn ghi audit entry.

## 6. Gói chẩn đoán

Xuất một file `.zip` gồm:

```
diagnostic-<date>.zip
  device.json      # model, iOS, dung lượng trống, pin, nhiệt
  permissions.json # camera, mic, location, bluetooth, notification
  upload-state.json# job + part, KHÔNG có URL
  integrity.json   # kết quả lần verify gần nhất
  logs.ndjson      # os.log 24h gần nhất, đã redact
```

**Redact trước khi ghi, không redact khi đọc.** Bỏ: presigned URL, token, email, free text do
người dùng nhập, toạ độ GPS. Giữ: id, enum, số liệu, status code
([07-security.md](07-security.md) §5).

Gói này là thứ người dùng gửi qua Zalo khi báo lỗi. Nếu nó chứa dữ liệu nhạy cảm thì mỗi báo lỗi
là một lần rò rỉ.

## 7. Cờ trạng thái hệ thống

Một danh sách, mỗi dòng một cờ, xanh/vàng/đỏ:

| Cờ | Đỏ khi |
|---|---|
| Quyền camera / mic / location / bluetooth | bị từ chối |
| Dung lượng trống | < `minFreeDiskBytes` (500MB) |
| Nhiệt độ | `.serious` trở lên |
| Pin | < 20% và đang có job upload |
| Kết nối | offline và có job pending |
| Audit chain | verify gãy |
| Đồng bộ metadata | lần sync cuối > 24h |

Đây cũng là chỗ đầu tiên nhìn vào khi người dùng nói "app không chạy".

## 8. Logging

Áp dụng chung toàn app, không riêng feature này:

1. `Logger` (os.log), subsystem `com.sitelog`, category theo module: `capture`, `upload`,
   `report`, `devicelink`, `sync`, `security`.
2. **Mọi action đều log, và log kèm data.** Success cũng log.
3. Mọi `catch` log **error object đầy đủ** (`String(reflecting:)`), không stringify thành message
   tự viết. Catch rộng, không catch hẹp.
4. **Không `print`.** CI fail nếu `grep -rn "print(" Sources/` ra kết quả.
5. Crashlytics init **đầu tiên** trong startup, trước mọi thứ khác — crash trong lúc init cái
   khác cũng phải bắt được.
6. Startup guard từng bước riêng, mỗi bước log rõ, không bọc cả init trong một `try`.

## 9. Constants

```swift
enum DiagnosticsConstants {
    static let throughputWindow: TimeInterval = 60
    static let integritySampleSize: Int = 50
    static let logRetentionHours: Int = 24
    static let staleSyncThreshold: TimeInterval = 86_400
    static let lowBatteryThreshold: Float = 0.20
}
```

## 10. Definition of done

1. Tạo được cả 6 tình huống ở §4 bằng tay → màn hình phát hiện đúng cả 6.
2. Gói chẩn đoán mở ra: **không có** URL ký, token, email, free text, toạ độ.
3. Dọn dẹp với 12 file `pending` trong máy → không file nào bị xoá.
4. `grep -rn "print(" Sources/` rỗng.
5. Zero warning.

## 11. Test

| Test | Loại |
|---|---|
| Detector tìm capture thiếu file / file mồ côi / temp mồ côi | unit, fake filesystem |
| Dọn dẹp không đụng file `pending` và `failed` | unit |
| Redaction: input có URL ký + email + free text → output sạch | unit, snapshot |
| Ước tính thời gian với throughput dao động không cho ra `NaN` / số âm | unit |
| Cờ trạng thái đúng cho 7 tổ hợp biên | unit |
| Job `uploading` không có task → reset về `pending` | unit |
