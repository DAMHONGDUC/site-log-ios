# SiteLog

App iOS ghi nhận hiện trạng công trình, **offline-first**, xuất biên bản PDF có chữ ký hai bên.

Người dùng: giám sát công trình, thầu phụ, đơn vị bàn giao nhà/căn hộ.

```
Tạo công trình → tạo đợt khảo sát → đi theo tầng/phòng, chụp và ghi lỗi
→ về chỗ có WiFi, app tự upload nền → xuất PDF biên bản có chữ ký
```

---

## 1. Bối cảnh quyết định kiến trúc

Công trình, hầm gửi xe, nhà trong hẻm đều sóng yếu hoặc không có sóng. Một đợt khảo sát ra
**150–250 file, vài GB**. Người dùng đóng app, bỏ điện thoại vào túi, đi tiếp.

Ba hệ quả không thương lượng:

1. **Mọi thao tác ghi phải hoàn tất offline.** Mạng là thứ đến sau, không phải điều kiện.
2. **Upload phải sống sót qua suspend, app termination và mất mạng giữa chừng.** Process
   mới sau cold launch không giữ lại gì trong RAM — mọi trạng thái phải ở trên disk.
3. **PDF biên bản là đầu ra người dùng trả tiền.** Không được cắt, không được xuất thiếu ảnh.

## 2. Nguyên tắc dữ liệu

`Capture` là **bất biến** sau khi tạo. Chỉ metadata mô tả (nhãn, vị trí, issue gắn kèm) là
sửa được. Đây là nguyên tắc *chain of custody* và là lý do tồn tại của app: biên bản chỉ có
giá trị khi ảnh trong đó chứng minh được là chưa bị thay.

Mỗi `Capture` mang `sha256` tính ngay sau khi ghi xong, trước khi ghi vào DB.

Chi tiết: [data-model.md](data-model.md).

## 3. Stack

| Vùng | Chọn |
|---|---|
| UI | SwiftUI, iOS 17+ |
| Kiến trúc | MVVM, module hoá bằng Swift Package Manager |
| Concurrency | Swift Concurrency — `actor` cho upload queue, `@MainActor` cho ViewModel |
| Local store | SwiftData |
| Media | AVFoundation (`AVCaptureSession`, `AVAssetWriter`) |
| Crypto | CryptoKit + iOS Data Protection, key trong Keychain |
| Thiết bị ngoài | CoreBluetooth |
| Transport | `URLSession` background configuration, viết tay |
| Object storage | Cloudflare R2, S3 multipart + presigned URL |
| Auth / metadata / crash | Firebase (Auth, Firestore, Crashlytics) |

## 4. Non-goals

Ghi rõ để không bị "tiện tay":

1. **KHÔNG dùng Firebase Storage `putFile()` cho media.** Nó chạy được, nhưng đóng kín:
   không reattach được vào upload dở sau cold launch, không chỉnh được `isDiscretionary`,
   không đặt được thứ tự ưu tiên.
2. **Không dùng `UIImagePickerController` / `PhotosPicker`** cho capture.
3. **Không dùng thư viện upload bên thứ ba.**
4. Firebase chỉ cho auth, metadata, crash. **Không chạm đường truyền file.**

## 5. Module

Group by feature, không group by kind. Dependency point inward — `Core` không import framework.

```
Packages/
  Core/           # entity, business rule, không import framework
  DesignSystem/   # token spacing/màu/type, component dùng chung
  Capture/        # AVFoundation pipeline
  UploadKit/      # upload engine — package độc lập, test được riêng
  DeviceLink/     # CoreBluetooth
  Reporting/      # sinh PDF
  Realtime/       # WebSocket progress channel
  Persistence/    # SwiftData
App/
```

`UploadKit` **không được biết gì về SiteLog**. Nó nhận file + metadata + endpoint + một
`UploadStore` do host inject. Tách được nó ra thành package dùng lại chỗ khác là tiêu chuẩn đúng.

## 6. Đặc tả feature

| # | Feature | File |
|---|---|---|
| — | Data model dùng chung | [data-model.md](data-model.md) |
| 01 | Công trình, đợt khảo sát, vị trí | [01-project-session.md](01-project-session.md) |
| 02 | Capture pipeline | [02-capture.md](02-capture.md) |
| 03 | Ghi nhận lỗi & ghép cặp trước/sau | [03-issue-tracking.md](03-issue-tracking.md) |
| 04 | Upload engine | [04-upload-engine.md](04-upload-engine.md) |
| 05 | Xuất PDF biên bản | [05-reporting.md](05-reporting.md) |
| 06 | DeviceLink — máy đo qua BLE | [06-device-link.md](06-device-link.md) |
| 07 | Bảo mật & audit log | [07-security.md](07-security.md) |
| 08 | Auth & metadata sync | [08-auth-sync.md](08-auth-sync.md) |
| 09 | Diagnostics & observability | [09-diagnostics.md](09-diagnostics.md) |
| 10 | Realtime progress channel (WebSocket) | [10-realtime-progress.md](10-realtime-progress.md) |

## 7. Giai đoạn

| Tuần | Việc |
|---|---|
| 1–2 | Scaffold SPM + **CI xanh từ ngày đầu**, SwiftData model, màn hình Project/Session/Location, camera cơ bản |
| 3–4 | Upload engine. Background session, chunk, resume, retry, state machine. **Ngồi lâu ở đây.** |
| 5–6 | Hash/GPS/metadata, export PDF, Face ID + Data Protection |
| 7–8 | BLE máy đo, WebSocket progress channel, pre-record buffer, diagnostics screen, mở rộng test |

Ship TestFlight từ **cuối tuần 4**. Không đợi hoàn hảo.

**Cắt nếu hụt thời gian**, theo thứ tự: pre-record buffer → audio → BLE thiết bị thật (giữ mock).
WebSocket ([10](10-realtime-progress.md)) cắt được không đau vì nó là kênh quan sát, nhưng nó rẻ
và là transport duy nhất ngoài HTTPS trong app — giữ nếu còn tuần 8.
**Giữ bằng mọi giá**: upload engine, hash + metadata, export PDF.

CI đẩy lên tuần 1 thay vì tuần 7: với một portfolio project, một suite test chạy xanh là tín
hiệu mạnh hơn feature thứ tư, và viết test sau khi code đã đông cứng thì đắt gấp đôi.

## 8. Conventions

Áp dụng `engineering-conventions` Part 1, dịch sang idiom Swift:

1. Group by feature. Dependency point inward. Across module chỉ import public surface.
2. Constants có `enum` riêng, không bolt lên model/view. Không raw literal ở call site.
   Mọi spacing/màu/type qua `DesignSystem` token.
3. **Mọi action đều log, và log kèm data.** `"Upload failed"` vô dụng;
   `"Upload failed — {captureId, part: 3/12, bytes: 4.1MB, status: 503}"` mới dùng được.
   Success cũng log.
4. Mọi `catch` đều log error object đầy đủ, không stringify thành message tự viết.
   Catch rộng, không catch hẹp. **Không `print`.**
5. Guard từng bước startup riêng, không bọc cả init trong một `try`. Crash reporting init đầu tiên.
6. Extract ở ~80 dòng. Variant là parameter, không phải hàm rẽ nhánh.
7. Không business logic trong `View`. View lo layout, ViewModel lo orchestration.
8. Explicit type, `let` mặc định.

## 9. Definition of done cho mỗi thay đổi

1. Build sạch, **zero warning**, từng package riêng.
2. Test **scoped** cho phần vừa đổi — không chạy cả suite.
3. Soát diff: magic literal, string hardcode hiện ra UI, `catch` không log, import xuyên
   boundary, constant bolt lên model.
4. Không có giá trị nào đọc từ file env/secret lọt vào diff hay log.
