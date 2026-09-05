# 04 — Upload engine (UploadKit)

Module: `Packages/UploadKit` — **package độc lập, không biết gì về SiteLog**

Đây là phần lõi và là phần sẽ bị hỏi kỹ nhất trong phỏng vấn. Làm chậm và làm đúng.

## 1. Mục tiêu

Đưa 150–250 file, vài GB, từ máy người dùng lên object storage, **sống sót qua**: mất mạng
giữa chừng, app bị suspend, app bị OS kill, người dùng reboot máy, và presigned URL hết hạn
trong lúc chờ.

## 2. Ranh giới package

`UploadKit` nhận: **file URL + metadata + endpoint + một `UploadStore` do host inject**. Nó
không import `Core`, không biết `Capture`, `Issue`, `Session` là gì.

```swift
public protocol UploadStore: Sendable {
    func upsert(_ job: UploadJobRecord) async throws
    func job(id: UploadJobID) async throws -> UploadJobRecord?
    func job(forTaskDescription key: String) async throws -> UploadJobRecord?
    func pendingJobs(limit: Int) async throws -> [UploadJobRecord]
    func updatePart(_ part: UploadPartRecord) async throws
    func delete(id: UploadJobID) async throws
}
```

`UploadJobRecord` / `UploadPartRecord` là **struct thuần, `Sendable`, `Codable`**, định nghĩa
trong `UploadKit`. App implement `UploadStore` bằng SwiftData ở tầng `Persistence` và map sang
struct này ở biên.

Đây là chỗ sửa mâu thuẫn của bản context đầu: nếu `UploadKit` tra thẳng SwiftData model của app
thì nó không còn độc lập, và cũng không test được nếu không dựng cả app. Với protocol này,
`UploadKit` ship kèm `InMemoryUploadStore` và toàn bộ state machine test được không cần app,
không cần DB, không cần mạng.

```
Packages/UploadKit/
  Sources/UploadKit/
    UploadCoordinator.swift      # actor, entry point công khai
    UploadStateMachine.swift     # thuần, không async, không I/O  ← test dày nhất ở đây
    ChunkPlanner.swift           # chia part, ghi file tạm
    PresignedURLProvider.swift   # protocol + implementation HTTP
    BackgroundSessionDelegate.swift
    Models/                      # UploadJobRecord, UploadPartRecord, UploadState
  Tests/UploadKitTests/
    InMemoryUploadStore.swift
    MockTransport.swift
```

## 3. Giao thức

S3 multipart upload qua presigned URL. Backend **không đụng vào bytes** (~100 dòng):

```
1. POST /uploads                     { key, byteSize, contentType, sha256 }
   → { uploadId, parts: [{ number, url, expiresAt }] }

2. PUT <presigned url>               body = file tạm của part
   → 200, header ETag

3. POST /uploads/:id/complete        { parts: [{ number, etag }] }
   → { remoteKey }

4. POST /uploads/:id/parts/refresh   { numbers: [3, 4, 5] }        ← BẮT BUỘC
   → { parts: [{ number, url, expiresAt }] }

5. DELETE /uploads/:id               abort, dọn part mồ côi trên R2
```

Endpoint (4) là thứ bản context đầu thiếu và là thứ sẽ hỏng chắc chắn: kịch bản lõi của app là
app bị kill rồi mở lại sau vài giờ, lúc đó presigned URL đã ký từ trước đã chết. Không có
refresh thì cold-launch resume trả về 403 hàng loạt và trông y hệt một bug retry.

Mọi request tới backend mang Firebase ID token; backend verify token trước khi ký URL. Không có
bước đó thì endpoint ký là một open relay ghi vào bucket của mình.

## 4. Ràng buộc iOS bắt buộc phải tuân

### 4.1 Chỉ dùng được upload task dạng file

Background `URLSession` chỉ nhận `uploadTask(with:fromFile:)`. Không data task, không stream,
không body in-memory. → **mỗi part phải ghi ra file tạm rồi mới enqueue**.

Hệ quả về dung lượng: một session vài GB mà giữ cả chunk tạm là nhân đôi disk. Bắt buộc:

1. Chỉ materialize trước **tối đa 2 part** cho mỗi job.
2. Xoá file part **ngay khi** nhận 200 + ETag.
3. Check free space trước khi plan job; dưới `minFreeDiskBytes` thì hoãn và báo người dùng.

### 4.2 `isDiscretionary` không phải lúc nào cũng được tôn trọng

Đặt `isDiscretionary = false` cho upload do người dùng chủ động — mặc định OS có thể dời tới
đêm khi máy vừa có mạng vừa cắm sạc, sai hoàn toàn với người muốn upload xong trước khi rời
công trường.

Nhưng: **task tạo ra khi app đang ở background bị OS coi là discretionary bất kể set gì.** Nên:

1. Enqueue đợt đầu **lúc app còn foreground** (người dùng bấm "Bắt đầu upload", hoặc tự động
   khi màn hình session mở và có WiFi).
2. UI nói đúng sự thật: "Đang tải lên" vs. "Sẽ tải khi máy rảnh" — đừng hứa cái OS không đảm bảo.
3. `sessionSendsLaunchEvents = true` để OS đánh thức app khi xong.

### 4.3 Cold launch: `taskIdentifier` không dùng làm khoá được

Sau khi app bị kill và mở lại, tạo lại session **cùng identifier**, xử lý
`application(_:handleEventsForBackgroundURLSession:completionHandler:)`, rồi tra ngược task →
part. Process hoàn toàn mới, không có gì trong RAM sống sót.

`taskIdentifier` chỉ unique trong phạm vi một session và **bị tái sử dụng** — dùng nó làm khoá
chính là đặt một quả bom hẹn giờ. Khoá đúng:

```swift
task.taskDescription = "\(jobID.rawValue)#\(partNumber)"
```

`taskDescription` được `URLSession` giữ nguyên qua relaunch. Lookup:

```swift
func urlSession(_ s: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    guard let key = task.taskDescription else { /* log + abandon */ return }
    Task { await coordinator.handleCompletion(key: key, response: task.response, error: error) }
}
```

Lúc khởi động, gọi `session.allTasks` và **đối chiếu hai chiều** với store:

| Tình huống | Xử lý |
|---|---|
| Task còn sống, store có record | Attach lại, không enqueue thêm |
| Task còn sống, store không có | Cancel task, log — record đã mất, không tin được |
| Store có `uploading`, không có task | Reset về `pending`, enqueue lại part đó |

Bước đối chiếu này là phần dễ bỏ sót nhất và là nguyên nhân của "upload treo mãi ở 60%".

Đối chiếu ở trên chỉ thấy phía client. Phía server có thể đã `complete` xong một job mà app
chưa kịp nhận response trước khi bị kill — kênh WebSocket ở [10-realtime-progress.md](10-realtime-progress.md)
gửi một `snapshot` giải quyết việc đó trong một round-trip. `UploadKit` **không import** package
đó; app layer nhận event rồi ghi qua `UploadStore`.

### 4.4 `timeoutIntervalForResource`

Đặt 7 ngày (`604800`). Một người dùng đi công trường 3 ngày không có WiFi vẫn phải upload được
khi về. Mặc định của background session đủ dài, nhưng đặt tường minh để không phụ thuộc mặc định.

## 5. Chọn chiến lược theo kích thước file

| File | Chiến lược |
|---|---|
| < 5 MB (hầu hết ảnh) | **Single PUT** presigned, 1 request |
| >= 5 MB (video, ảnh RAW) | Multipart, part đều nhau `8 MB` |

S3 quy định part tối thiểu 5MB (trừ part cuối), và **R2 còn nghiêm hơn: mọi part trừ part cuối
phải bằng nhau đúng byte**. Vì vậy `ChunkPlanner` chia theo kích thước cố định, không chia
"thành N phần bằng nhau".

Đưa ảnh 3MB qua multipart là 3 round-trip cho một thứ 1 request làm xong — với 200 ảnh trên
mạng 3G, đó là vài phút mất trắng.

## 6. State machine

Đây là trái tim của package và là thứ đem đi phỏng vấn được. **Thuần, đồng bộ, không I/O.**

```
                  ┌──────────────────────────────┐
                  ↓                              │
pending → planning → uploading ⇄ waitingForURL ──┘
             │           │  │
             │           │  └→ waitingForNetwork ─┘
             │           ↓
             │       completing → synced
             ↓           │
          failed ←───────┘
```

```swift
public struct UploadStateMachine {
    public enum Event {
        case planned(parts: [UploadPartRecord])
        case partSucceeded(number: Int, etag: String)
        case partFailed(number: Int, reason: FailureReason)
        case urlsRefreshed(parts: [UploadPartRecord])
        case networkBecameAvailable
        case completed(remoteKey: String)
        case cancelledByUser
    }

    public enum Effect {
        case enqueuePart(Int)
        case refreshURLs(numbers: [Int])
        case callComplete(etags: [Int: String])
        case scheduleRetry(number: Int, after: TimeInterval)
        case abort(reason: FailureReason)
        case deleteTempFile(number: Int)
    }

    public func reduce(state: UploadJobState, event: Event) -> (UploadJobState, [Effect])
}
```

`reduce` là hàm thuần: cùng input luôn cho cùng output, không đụng mạng, disk hay clock.
`UploadCoordinator` (actor) là thứ duy nhất thực thi `Effect`. Tách như vậy thì mọi kịch bản
khó — kill giữa chừng, URL hết hạn, part cuối fail — test được bằng vài dòng, không cần mạng.

### Phân loại lỗi

Đây là chỗ quyết định engine chạy đúng hay chạy loạn:

| Nguyên nhân | `FailureReason` | Xử lý |
|---|---|---|
| 403 / 401 trên presigned URL | `.urlExpired` | → `waitingForURL`, **không tính retry budget** |
| Không có mạng, `NSURLErrorNotConnectedToInternet` | `.offline` | → `waitingForNetwork`, không tính budget |
| 500, 502, 503, 504 | `.serverTransient` | retry, có tính budget |
| Timeout | `.timeout` | retry, có tính budget |
| 400, 404, 411, 413 | `.permanent` | abort ngay, không retry |
| Checksum lệch, ETag không khớp | `.integrity` | abort, đánh dấu để người dùng thấy |

URL hết hạn và mất mạng **không được tính vào retry budget**. Cả hai đều là trạng thái bình
thường của app này, không phải lỗi; tính vào budget thì một chuyến đi công trường nửa ngày là
đủ đốt sạch retry và mọi thứ rơi vào `failed`.

### Retry

```
delay = min(base * 2^attempt, cap) * jitter
base = 2s, cap = 300s, jitter = random(0.8...1.2)
maxAttempts = 5 (chỉ đếm .serverTransient và .timeout)
```

Jitter bắt buộc: 200 file cùng fail lúc mất sóng, không có jitter thì cả 200 cùng retry một
lúc lúc có sóng lại và tự tạo ra một đợt DDoS vào chính backend của mình.

## 7. Chính sách

1. **Thứ tự ưu tiên** theo `priority` do host truyền vào (bảng ở
   [03-issue-tracking.md](03-issue-tracking.md)): ảnh của issue nghiêm trọng trước, video sau.
   Hàng đợi là priority queue, không phải FIFO.
2. **Toggle "chỉ upload qua WiFi"** — `allowsCellularAccess = false`, mặc định **bật**. Người
   dùng đi công trường cả ngày, upload vài GB qua 4G là hoá đơn không ai muốn.
3. **Dedupe bằng `sha256`.** Cùng hash trong cùng project → bỏ qua, trỏ `remoteKey` sang object
   đã có, log rõ. Người dùng chụp lại cùng một chỗ nhiều lần là chuyện bình thường.
4. **Song song**: tối đa 3 job cùng lúc, `httpMaximumConnectionsPerHost = 4`. Cao hơn thì trên
   mạng công trường yếu, mọi request cùng timeout.
5. **Không tự xoá file local** sau khi `synced`. Chỉ dọn khi người dùng chủ động, và chỉ những
   file đã `synced` (xem [09-diagnostics.md](09-diagnostics.md)).

## 8. Constants

```swift
public enum UploadConstants {
    public static let partSizeBytes: Int = 8 * 1024 * 1024
    public static let singlePutThresholdBytes: Int = 5 * 1024 * 1024
    public static let maxConcurrentJobs: Int = 3
    public static let maxConnectionsPerHost: Int = 4
    public static let maxMaterializedPartsPerJob: Int = 2
    public static let minFreeDiskBytes: Int64 = 500 * 1024 * 1024
    public static let resourceTimeout: TimeInterval = 604_800
    public static let retryBaseDelay: TimeInterval = 2
    public static let retryCapDelay: TimeInterval = 300
    public static let retryJitterRange: ClosedRange<Double> = 0.8...1.2
    public static let maxRetryAttempts: Int = 5
    public static let sessionIdentifier: String = "com.sitelog.upload.background"
}
```

## 9. Logging

Mọi chuyển trạng thái đều log, kèm data. Success cũng log.

```swift
logger.info("Upload part succeeded", metadata: [
    "jobID": "\(job.id)", "part": "\(number)/\(job.partCount)",
    "bytes": "\(partSize)", "elapsedMs": "\(elapsed)", "attempt": "\(attempt)"
])
logger.error("Upload part failed", metadata: [
    "jobID": "\(job.id)", "part": "\(number)/\(job.partCount)",
    "status": "\(statusCode)", "reason": "\(reason)", "attempt": "\(attempt)",
    "error": "\(String(reflecting: error))"
])
```

**Không log presigned URL** — nó chứa credential ký. Log `key` và `partNumber` là đủ để debug.

## 10. Rủi ro đã biết

1. **Part mồ côi trên R2** khi job bị abort. Gọi `DELETE /uploads/:id`; nếu không gọi được thì
   bucket lifecycle rule dọn multipart dở sau 7 ngày — cấu hình phía R2, ghi vào runbook.
2. **Đầy disk giữa chừng** → dừng plan job mới, giữ job đang chạy, báo người dùng số cụ thể.
3. **Đổi tài khoản khi còn job pending** → job của user cũ phải bị cancel + xoá temp, không
   được upload vào bucket của user mới.
4. **Clock skew** làm `expiresAt` tính sai. Đừng tin đồng hồ máy: coi 403 là nguồn sự thật, còn
   `expiresAt` chỉ để refresh chủ động sớm.

## 11. Definition of done

1. 200 file / 2GB upload xong qua WiFi, tất cả `synced`, hash server khớp hash local.
2. **Kill app** giữa chừng (`Stop` trong Xcode) → mở lại → tự resume, không mất, không upload lại
   part đã xong.
3. **Chế độ máy bay** giữa chừng → về `waitingForNetwork`, bật lại mạng → tự tiếp, retry budget
   không giảm.
4. Presigned URL hết hạn (test bằng TTL 60s) → tự refresh, không vào `failed`.
5. Toggle "chỉ WiFi" bật + đang 4G → không có byte nào bay.
6. Zero warning, `UploadKit` build được **độc lập** không cần app.

## 12. Test

State machine phải có unit test độc lập với network. Mock transport layer.
**Đây là thứ đem đi phỏng vấn được** — viết cho ra hồn.

| Test | Loại |
|---|---|
| `reduce` cho mọi cặp (state × event) — bảng đầy đủ, không bỏ ô nào | unit, thuần |
| Part cuối fail → job không `synced`, không gọi `complete` | unit |
| `.urlExpired` không giảm retry budget; `.serverTransient` có giảm | unit |
| Hết budget → `failed`, temp file được xoá, file gốc **không** bị xoá | unit |
| Backoff sinh đúng dãy delay với jitter bị stub cố định | unit, inject RNG |
| `ChunkPlanner`: part đều nhau, part cuối lẻ, file đúng bội số `partSize` | unit |
| File < ngưỡng → chọn single PUT, không tạo `uploadId` | unit |
| Dedupe: hai job cùng `sha256` → job thứ hai `synced` ngay, 0 request | unit |
| Cold launch reconcile: 3 tình huống ở §4.3 | unit, `InMemoryUploadStore` |
| Priority queue trả đúng thứ tự với 5 job trộn severity và kind | unit |
| Full flow qua `MockTransport` có inject 503 ở part 3 | integration, `UploadKit` |
| Kill app thật giữa chừng trên máy thật | manual, checklist trong PR |

`MockTransport` implement `protocol UploadTransport` (cùng surface với phần bọc `URLSession`),
cho phép script sẵn response theo từng part: 200, 403, 503, timeout, ETag sai.
