# 08 — Auth & metadata sync

Module: `App/Features/Auth`, `App/Features/Sync`

Firebase **chỉ** cho auth, metadata, crash. **Không chạm đường truyền file** — media đi qua
[UploadKit](04-upload-engine.md) lên R2.

## 1. Mục tiêu

1. Đăng nhập một lần, giữ phiên lâu, mở app offline vẫn dùng được đầy đủ.
2. Metadata (Project/Session/Location/Issue — **không phải media**) đồng bộ giữa các thiết bị.
3. Cấp quyền cho backend ký presigned URL.

## 2. Phạm vi

**Trong phạm vi**

1. Firebase Auth: Sign in with Apple + email/password.
2. ID token → header `Authorization` cho mọi request tới backend upload.
3. Đồng bộ metadata hai chiều qua Firestore, offline-first.
4. Xoá tài khoản (bắt buộc để lên App Store).

**Ngoài phạm vi**

1. Đồng bộ media qua Firestore. Firestore không phải chỗ để media, và document giới hạn 1MB.
2. Chia sẻ project nhiều người, phân quyền (v2). Model hiện tại: mỗi project một chủ.
3. SSO doanh nghiệp.

## 3. Nguyên tắc offline-first

**Local là nguồn sự thật khi đang ghi. Server là nguồn sự thật khi đã sync.**

1. Mọi thao tác ghi vào SwiftData **trước**, trả về UI ngay, đẩy lên Firestore sau.
2. **Không màn hình nào chờ mạng.** Không spinner chặn, không "đang tải…" ở màn hình chính.
3. Mở app offline sau khi đã đăng nhập → vào thẳng, không hỏi lại. Firebase Auth giữ được
   phiên offline; chỉ khi refresh token hết hạn (mặc định ~1 năm hoặc bị thu hồi) mới bắt đăng
   nhập lại.

Không tuân nguyên tắc này thì mọi thứ khác trong app vô nghĩa: người dùng đang ở hầm gửi xe.

## 4. Token cho backend upload

```swift
func authorizedRequest(_ base: URLRequest) async throws -> URLRequest {
    let token = try await Auth.auth().currentUser?.getIDToken(forcingRefresh: false)
    var request = base
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    return request
}
```

1. `getIDToken` tự refresh khi sắp hết hạn (token sống 1 giờ). **Không tự cache tay** — đây là
   chỗ dễ tự tạo bug hết hạn nhất.
2. Backend verify token bằng Firebase Admin SDK **trước khi ký URL**. Không có bước này thì
   endpoint ký là open relay vào bucket của mình.
3. Object key gắn uid: `{uid}/{projectID}/{sessionID}/{captureID}.{ext}` — backend từ chối ký
   nếu key không khớp uid trong token.
4. Backend trả 401 → `UploadKit` chuyển job về `waitingForURL` (không tính retry budget), app
   refresh token rồi thử lại. Cùng cơ chế với presigned URL hết hạn.

## 5. Đồng bộ metadata

Firestore, bật `isPersistenceEnabled` (mặc định trên iOS).

```
users/{uid}/projects/{projectID}
users/{uid}/projects/{projectID}/sessions/{sessionID}
users/{uid}/projects/{projectID}/locations/{locationID}
users/{uid}/projects/{projectID}/issues/{issueID}
users/{uid}/phrases/{phraseID}
```

`Capture` **không** sync toàn bộ — chỉ sync bản mô tả nhẹ (id, kind, sha256, capturedAt,
remoteKey, locationID). Bytes ở R2, không ở Firestore.

### Giải quyết xung đột

Ưu tiên đơn giản và dự đoán được, không cố tỏ ra thông minh:

| Loại | Chiến lược |
|---|---|
| `Capture` | Không bao giờ xung đột — bất biến, id là UUID sinh ở client |
| `Issue`, `Location`, `Project` | Last-write-wins theo `updatedAt` server timestamp |
| `Session.state` | Monotonic: `draft < active < closed < exported`, **chỉ tiến, không lùi** |

`Session.state` phải monotonic vì máy B offline có thể ghi `active` đè lên `exported` của máy A
và mở khoá lại một biên bản đã ký. Đó là lỗi phá giá trị pháp lý của sản phẩm.

### Sync worker

`actor MetadataSyncEngine`, chạy khi: app vào foreground, mạng vừa có lại, và mỗi
`syncInterval`. Không chạy mỗi lần ghi — 80 Location tạo hàng loạt sẽ thành 80 write.

Batch tối đa `maxBatchWrites` document mỗi lần, exponential backoff khi lỗi, và **log số liệu
cụ thể** mỗi vòng: `{pushed, pulled, conflicts, elapsedMs}`.

## 6. Xoá tài khoản

Bắt buộc, và phải làm cho đúng:

1. Trong app, không phải qua email hỗ trợ.
2. Reauthenticate trước khi xoá.
3. Xoá: Firestore subtree của uid, object R2 theo prefix `{uid}/`, local store, Keychain, file media.
4. Hiện rõ **trước khi xoá**: bao nhiêu project, bao nhiêu ảnh, bao nhiêu GB.
5. Ghi audit entry cuối cùng trước khi xoá ([07-security.md](07-security.md)).

## 7. Constants

```swift
enum SyncConstants {
    static let syncInterval: TimeInterval = 300
    static let maxBatchWrites: Int = 400          // Firestore giới hạn 500/batch
    static let backoffBaseDelay: TimeInterval = 5
    static let backoffMaxDelay: TimeInterval = 600
}
```

## 8. Rủi ro đã biết

1. **Đổi tài khoản khi còn job upload pending.** Cancel toàn bộ job của uid cũ, xoá temp part,
   **không** để job cũ upload vào prefix của uid mới.
2. **Firestore quota.** 80 Location + 200 Capture metadata mỗi session; với người dùng nhiều
   công trình, free tier hết nhanh. Batch write và theo dõi số liệu ngay từ đầu.
3. **Token bị thu hồi** (đổi mật khẩu ở máy khác) → mọi request 401. Xử lý một chỗ duy nhất ở
   interceptor, không rải `if statusCode == 401` khắp nơi.
4. **Sign in with Apple ẩn email** → không có email thật. Đừng thiết kế gì phụ thuộc email.

## 9. Definition of done

1. Đăng nhập → bật máy bay → kill app → mở lại: **vào thẳng**, dùng đủ mọi feature ghi.
2. Tạo project trên máy A offline → có mạng → hiện trên máy B trong dưới 60 giây.
3. Máy A `exported` một session, máy B offline set `active` → sau sync, state vẫn `exported`.
4. Token hết hạn giữa lúc upload → tự refresh, job không vào `failed`.
5. Xoá tài khoản → không còn object nào dưới prefix `{uid}/` trên R2.

## 10. Test

| Test | Loại |
|---|---|
| `SessionState` merge monotonic cho cả 16 cặp | unit, `Core` |
| LWW theo `updatedAt`, tie-break ổn định (theo id) | unit |
| Đổi tài khoản → job của uid cũ bị cancel, temp bị xoá | unit, `InMemoryUploadStore` |
| 401 → refresh token đúng một lần, không refresh storm khi 10 request cùng 401 | unit, mock |
| Sync 500 document chia đúng 2 batch | unit |
| Firestore security rule: uid A không đọc được `users/{B}` | integration, emulator |
| Backend từ chối ký key không khớp uid | integration, backend test |
