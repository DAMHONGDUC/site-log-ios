# 07 — Bảo mật & audit log

Module: `App/Features/Security`, `Packages/Core`

## 1. Mục tiêu

Media và biên bản là bằng chứng nghiệm thu. Ba yêu cầu: **không đọc được nếu mất máy**, **không
sửa được mà không để lại vết**, **không rò rỉ ra log/analytics**.

## 2. At-rest: Data Protection, không tự AES-GCM cho media

Quyết định này khác bản context đầu, và đây là lý do.

Bản đầu ghi "file mã hoá at-rest bằng AES-GCM (CryptoKit)". Nhưng background `URLSession` chỉ
upload được **file thô trên disk** ([04-upload-engine.md](04-upload-engine.md) §4.1). Nếu media
được AES-GCM thì trước mỗi lần upload phải giải mã ra một file tạm plaintext — tức là thứ vừa
mã hoá lại nằm trần trên disk suốt thời gian upload, đúng lúc app đang ở background và không
kiểm soát được. Tự mã hoá ở đây làm bảo mật **kém đi** so với không làm gì, đồng thời nhân đôi
disk và thêm một hạng mục phải test.

Cách đúng trên iOS:

| Dữ liệu | Bảo vệ |
|---|---|
| Media (`media/`) | `FileProtectionType.completeUnlessOpen` — AES-256 hardware-backed, key gắn với passcode, Secure Enclave giữ key |
| SwiftData store | `.complete` |
| Part tạm của upload (`tmp/upload-parts/`) | `.completeUnlessOpen`, xoá ngay sau khi PUT xong |
| Export bundle (PDF + media, đưa ra ngoài app) | **AES-GCM (CryptoKit)**, key sinh riêng cho từng bundle |
| Audit log chain | **HMAC-SHA256 (CryptoKit)**, key trong Keychain |
| Firebase ID token, refresh token | Keychain, `.whenUnlockedThisDeviceOnly` |

`.completeUnlessOpen` là mấu chốt: file được mã hoá khi máy khoá, nhưng file đang mở vẫn đọc
tiếp được — đúng thứ background upload cần. `.complete` sẽ làm upload chết ngay khi người dùng
bỏ máy vào túi, tức là chính xác kịch bản sử dụng của app.

CryptoKit vẫn được dùng ở hai chỗ nó thực sự đúng: **export bundle** và **audit chain**. Cả hai
đều là dữ liệu rời khỏi vùng kiểm soát của iOS, nơi Data Protection không còn tác dụng.

## 3. Face ID

1. `LAContext.evaluatePolicy(.deviceOwnerAuthentication)` — có fallback passcode, vì Face ID hỏng
   trong mũ bảo hộ và khẩu trang là chuyện thường ở công trường.
2. Gate khi: mở app từ cold launch, và quay lại foreground sau `lockTimeout`.
3. Che nội dung trong app switcher: `sceneWillResignActive` phủ một overlay.
4. **Face ID là gate UI, không phải khoá dữ liệu.** Khoá dữ liệu là Data Protection ở §2.
   Đừng nhầm hai thứ — người dùng jailbreak/backup vẫn đọc được nếu chỉ có Face ID.
5. Item Keychain nhạy cảm dùng `SecAccessControl` với `.biometryCurrentSet`: đổi Face ID đăng ký
   thì item mất, đúng ý muốn.

## 4. Audit log

Ghi lại **mọi** lần xem / xoá / export / loại khỏi báo cáo / đổi metadata.

```swift
struct AuditEntry: Codable, Sendable {
    let id: UUID
    let action: AuditAction        // .viewCapture / .exportReport / .excludeFromReport / ...
    let subjectID: String          // captureID / sessionID
    let actorID: String            // Firebase uid
    let occurredAt: Date
    let previousEntryHMAC: String  // chain
    let hmac: String               // HMAC-SHA256(key, canonical(fields) + previousEntryHMAC)
}
```

Chain HMAC nghĩa là: xoá hay sửa một entry giữa chừng làm gãy chuỗi và phát hiện được. Không có
chain thì audit log chỉ là một bảng ghi chú mà bất kỳ ai có DB đều sửa được.

1. Key HMAC sinh lần đầu, lưu Keychain `.whenUnlockedThisDeviceOnly`, **không bao giờ rời máy**.
2. Verify chain lúc khởi động (bất đồng bộ, không chặn UI); gãy → cờ đỏ trong Diagnostics
   ([09-diagnostics.md](09-diagnostics.md)) và ghi Crashlytics non-fatal.
3. Audit log **không bao giờ bị xoá** bởi thao tác người dùng, kể cả khi xoá Project.

## 5. Không rò rỉ

Quy tắc cứng, soát trong mọi PR:

1. **Không log presigned URL** (chứa credential ký), không log token, không log key Keychain.
2. **Không log nội dung do người dùng nhập** — mô tả lỗi có thể chứa tên, số căn hộ, số điện thoại.
   Log `issueID`, không log `issue.detail`.
3. Analytics/Crashlytics chỉ nhận **ID và enum**, không nhận free text, không nhận toạ độ GPS.
4. `deviceModel` được phép; `identifierForVendor` chỉ dùng trong crash report.
5. **Không `print`.** `Logger` (os.log) với subsystem/category theo module, `privacy: .private`
   mặc định cho mọi giá trị động.

```swift
logger.info("Report exported", metadata: [
    "sessionID": "\(session.id)", "pageCount": "\(pages)", "bytes": "\(size)"
])
// KHÔNG: "\(session.note)", "\(presignedURL)", "\(user.email)"
```

## 6. Secret và cấu hình

1. `GoogleService-Info.plist` và endpoint backend **không commit**. CI ghi từ secret.
2. Không có API key nào nằm trong source. R2 credential **chỉ ở backend** — app không bao giờ
   thấy access key, đó là toàn bộ lý do dùng presigned URL.
3. `.xcconfig` cho từng môi trường, file thật gitignore, file `.example` commit.
4. Soát diff mỗi PR: không có giá trị nào đọc từ file env/secret lọt vào diff hay log.

## 7. Quyền riêng tư

1. Ảnh có GPS. Nói rõ trong onboarding, và cho **tắt ghi toạ độ** ở Settings.
2. Privacy manifest (`PrivacyInfo.xcprivacy`) khai đúng: location, device ID, crash data.
3. Xoá tài khoản → xoá dữ liệu server trong 30 ngày, xoá local ngay. Yêu cầu bắt buộc của App Store.

## 8. Constants

```swift
enum SecurityConstants {
    static let lockTimeout: TimeInterval = 300
    static let keychainService: String = "com.sitelog.keys"
    static let auditHMACKeyTag: String = "com.sitelog.audit.hmac"
    static let exportKeyLengthBytes: Int = 32
}
```

## 9. Rủi ro đã biết

1. **Mất key HMAC** (khôi phục máy mới) → chain cũ không verify được. Chấp nhận: audit log là
   per-device, và ghi rõ điều đó trong Diagnostics thay vì báo động giả.
2. **`.completeUnlessOpen` vẫn cho đọc khi máy đang mở khoá.** Đó là đánh đổi có ý thức để
   background upload chạy được; ghi vào threat model chứ đừng giả vờ không có.
3. **Face ID bypass bằng cách kill app** nếu gate đặt sai chỗ — gate phải ở `RootView`, không
   phải ở một sheet.

## 10. Definition of done

1. Máy khoá → media không đọc được qua file sharing / backup không mã hoá.
2. Background upload vẫn chạy khi máy khoá (chứng minh `.completeUnlessOpen` đúng).
3. Sửa tay một `AuditEntry` trong DB → verify chain báo gãy.
4. `grep -rn "print(" Sources/` không ra kết quả.
5. Soát toàn bộ log của một phiên chụp 20 ảnh: không có URL ký, token, hay free text nào.

## 11. Test

| Test | Loại |
|---|---|
| HMAC chain: thêm 100 entry rồi verify → hợp lệ | unit |
| Sửa entry thứ 50 → verify phát hiện đúng vị trí gãy | unit |
| Xoá entry giữa chuỗi → phát hiện | unit |
| AES-GCM export bundle: encrypt → decrypt → khớp byte gốc | unit |
| Sai key → decrypt throw, không trả rác | unit |
| File mới tạo có đúng `FileProtectionType` mong đợi | integration |
| Keychain item `.biometryCurrentSet` không đọc được khi chưa auth | integration, máy thật |
| Redaction: `AuditEntry` + log metadata không chứa free text | unit, snapshot log |
