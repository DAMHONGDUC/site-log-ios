# 10 — Realtime progress channel (WebSocket)

Module: `Packages/Realtime`

Kênh **quan sát** giữa app và backend, chạy trên `URLSessionWebSocketTask` viết tay. Bổ sung cho
[UploadKit](04-upload-engine.md), **không thay thế và không điều khiển nó**.

## 1. Vấn đề nó giải

Sau khi app PUT xong part cuối và gọi `complete`, có một khoảng thời gian server còn đang ghép
part và verify checksum. Trong khoảng đó app không biết gì. Ba tình huống thật:

1. **App gọi `complete` rồi bị kill trước khi nhận response.** Job thật ra đã xong trên server,
   nhưng local vẫn `uploading`. Không có kênh nào báo lại thì job treo cho tới lần reconcile sau.
2. **Cold launch sau vài giờ.** App cần biết trong 243 job thì server đã nhận được những cái nào,
   trước khi enqueue lại. Hỏi từng cái là 243 request.
3. **Server verify hash lệch.** Đây là tín hiệu quan trọng nhất của app (chain of custody bị phá)
   và hiện không có đường nào để server báo về.

Cả ba đều là **server biết trước app**. Đó là định nghĩa của một kênh push.

## 2. Tại sao WebSocket, không phải thứ khác

| Phương án | Vì sao loại |
|---|---|
| Polling `GET /uploads/status` | 243 job, poll 10s = đốt pin và data trên mạng công trường |
| Server-Sent Events | Một chiều; app cần gửi `subscribe` theo session và ping ngược |
| APNs silent push | Không đảm bảo giao, OS bóp tần suất, sai công cụ cho progress |
| **WebSocket** | Hai chiều, một kết nối, tự viết bằng `URLSessionWebSocketTask` |

Đây cũng là chỗ dùng đúng của một transport không phải HTTP request/response trong app: **BLE cho
control ([06](06-device-link.md)), WebSocket cho state, HTTPS cho bytes ([04](04-upload-engine.md))**.
Mỗi transport làm đúng việc nó giỏi.

## 3. Ranh giới — quan trọng nhất trong file này

**WebSocket là kênh quan sát. Upload phải chạy đủ 100% khi WebSocket chết.**

```
UploadKit  ──(không biết gì về Realtime)──→  chạy độc lập, nguồn sự thật local
                                                       ↑
Realtime   ──→ RealtimeEvent ──→ App layer ──→ reconcile vào UploadStore
```

1. `UploadKit` **không import** `Realtime`. `Realtime` **không import** `UploadKit`.
2. App layer nối hai đầu: nhận `RealtimeEvent`, dịch sang thao tác trên `UploadStore`.
3. Sự kiện từ WebSocket **chỉ được phép đẩy job tiến tới `synced`**, không bao giờ đẩy lùi.
   Server nói "xong" thì tin; server im lặng không có nghĩa là "chưa xong".
4. Tắt WebSocket bằng feature flag → app hoạt động y hệt, chỉ chậm biết tin hơn.

Ranh giới này là thứ khiến kênh này an toàn để thêm vào. Không có nó, một bug trong WebSocket
thành một bug mất dữ liệu.

## 4. Giao thức

JSON, một message một dòng.

### Client → Server

```json
{ "type": "auth",      "token": "<firebase id token>" }
{ "type": "subscribe", "sessionID": "…" }
{ "type": "ping",      "at": 1757000000 }
```

### Server → Client

```json
{ "type": "jobCompleted", "jobID": "…", "remoteKey": "…", "sha256": "…" }
{ "type": "jobFailed",    "jobID": "…", "reason": "integrity|expired|internal" }
{ "type": "snapshot",     "sessionID": "…", "completed": ["…"], "failed": ["…"] }
{ "type": "pong",         "at": 1757000000 }
```

`snapshot` là message đầu tiên sau khi `subscribe` — đây là thứ giải quyết tình huống §1.2 trong
một round-trip thay vì 243.

### Auth

Token đi trong **message `auth` đầu tiên**, không đi trong query string của URL. URL nằm trong
log server, log proxy và lịch sử — credential không được đặt ở đó. Server đóng kết nối nếu không
nhận `auth` trong `authTimeout`.

Token hết hạn (1 giờ) trong lúc kết nối còn mở → server gửi `close` code `4001`, client refresh
token và nối lại. Cùng cơ chế với 401 ở [08-auth-sync.md](08-auth-sync.md) §4.

## 5. Vòng đời

```
disconnected → connecting → authenticating → subscribed
      ↑                                          │
      └────────── backoff ←── failed ←───────────┘
```

Kết nối **chỉ khi**:

1. App ở foreground, **và**
2. Có ít nhất một job chưa `synced`, **và**
3. Đang có mạng cho phép (tôn trọng toggle "chỉ WiFi").

Đóng ngay khi app vào background. Không cố giữ WebSocket sống ở background — iOS sẽ đóng nó và
mọi nỗ lực giữ chỉ đốt pin. Trạng thái lúc app ở background là việc của background
`URLSession`, không phải của kênh này.

### Ping

`URLSessionWebSocketTask` **không tự ping**. Không ping thì NAT trên mạng di động cắt kết nối
im lặng và app tưởng vẫn đang nối. Tự gửi `ping` mỗi `pingInterval`; không có `pong` trong
`pongTimeout` thì coi như chết và reconnect.

### Nhận message

`receive(completionHandler:)` chỉ nhận **một** message. Sau mỗi lần nhận phải gọi lại — quên
gọi lại là bug im lặng kinh điển nhất của API này.

```swift
private func listen() {
    task.receive { [weak self] result in
        guard let self else { return }
        switch result {
        case .success(let message):
            Task { await self.handle(message) }
            self.listen()                       // ← bắt buộc
        case .failure(let error):
            logger.error("WebSocket receive failed", metadata: [
                "state": "\(self.state)", "error": "\(String(reflecting: error))"
            ])
            Task { await self.scheduleReconnect() }
        }
    }
}
```

### Reconnect

Backoff riêng, **không dùng chung** với retry của upload: `base 1s`, `cap 60s`, jitter
`0.8...1.2`, không giới hạn số lần (kênh phụ, thất bại không phải lỗi). Nối lại xong thì
`subscribe` lại và xử lý `snapshot` mới — không cố replay message đã mất.

Đây là lý do thiết kế `snapshot`: kênh không cần đảm bảo giao từng message, chỉ cần đảm bảo
trạng thái đúng sau mỗi lần nối lại.

## 6. Xử lý sự kiện ở app layer

| Event | Thao tác |
|---|---|
| `jobCompleted`, local `uploading` hoặc `failed` | → `synced`, lưu `remoteKey`, xoá temp part |
| `jobCompleted`, local đã `synced` | bỏ qua, log ở mức debug |
| `jobFailed` reason `integrity` | → `failed`, cờ đỏ trong [Diagnostics](09-diagnostics.md), Crashlytics non-fatal |
| `jobFailed` reason `expired` | → `waitingForURL`, refresh URL, **không tính retry budget** |
| `snapshot` | diff với `UploadStore`, chỉ áp phần đẩy tiến |
| `jobID` không có trong local store | bỏ qua + log — có thể là job của thiết bị khác cùng tài khoản |

Mọi thao tác đi qua `UploadStore`, không sửa thẳng SwiftData từ handler.

## 7. Constants

```swift
public enum RealtimeConstants {
    public static let pingInterval: TimeInterval = 30
    public static let pongTimeout: TimeInterval = 10
    public static let authTimeout: TimeInterval = 5
    public static let reconnectBaseDelay: TimeInterval = 1
    public static let reconnectMaxDelay: TimeInterval = 60
    public static let reconnectJitterRange: ClosedRange<Double> = 0.8...1.2
    public static let maxMessageBytes: Int = 64 * 1024
}
```

`maxMessageBytes` là giới hạn cứng: message lớn hơn thì đóng kết nối và log. Không parse JSON
kích thước tuỳ ý từ mạng.

## 8. Rủi ro đã biết

1. **Server nói "xong" nhưng thật ra chưa.** Đây là rủi ro nghiêm trọng nhất — nó có thể dẫn tới
   xoá file local chưa upload. Giảm thiểu: `jobCompleted` phải kèm `sha256`, app **đối chiếu với
   hash local** trước khi đánh dấu `synced`. Lệch → coi như `integrity`, không tin server.
2. **Message trùng.** Xử lý idempotent theo `jobID`; áp cùng một `jobCompleted` mười lần cho kết
   quả y hệt một lần.
3. **Đổi tài khoản khi WebSocket đang mở** → đóng ngay, không xử lý message tồn đọng của uid cũ.
4. **Kênh này không được trở thành phụ thuộc.** Soát định kỳ: xoá `Packages/Realtime` khỏi build,
   app phải vẫn compile và upload vẫn xong. Nếu không, ranh giới §3 đã vỡ.

## 9. Definition of done

1. 50 job upload, WebSocket mở → tất cả chuyển `synced` do event, không cần poll.
2. **Tắt hẳn WebSocket** (feature flag off) → 50 job vẫn `synced` đủ, chỉ chậm hơn.
3. Ngắt mạng 2 phút giữa chừng → tự nối lại, `snapshot` đưa trạng thái về đúng.
4. Server gửi `jobCompleted` với `sha256` sai → job **không** thành `synced`, cờ đỏ hiện lên.
5. App vào background → kết nối đóng trong 1 giây, không giữ task treo.
6. Zero warning, `Realtime` build độc lập, **không import `UploadKit`**.

## 10. Test

| Test | Loại |
|---|---|
| `RealtimeEvent` decode đúng cho cả 4 message type + payload rác | unit, thuần |
| Message > `maxMessageBytes` → đóng kết nối, không parse | unit |
| State machine: mất `pong` quá `pongTimeout` → `failed` → backoff | unit, inject clock |
| Backoff không vượt `reconnectMaxDelay`, có jitter | unit, inject RNG |
| `jobCompleted` với hash lệch → không `synced` | unit |
| `jobCompleted` áp 10 lần → kết quả bằng áp 1 lần (idempotent) | unit |
| `snapshot` chỉ đẩy tiến, không đẩy lùi trạng thái | unit |
| Event cho `jobID` lạ → bỏ qua, không crash | unit |
| Full flow với mock WebSocket server (SwiftNIO, trong test target) | integration |
| Xoá `Realtime` khỏi Package.swift → app vẫn build | CI, job riêng |

Job CI cuối cùng là thứ giữ cho ranh giới §3 không mục theo thời gian.
