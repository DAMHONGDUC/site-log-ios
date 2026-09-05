# 03 — Ghi nhận lỗi & ghép cặp trước/sau

Module: `App/Features/Issues`, `Packages/Core`

Đây là **tính năng nghiệp vụ chính**. Chụp ảnh thì app nào cũng làm được; thứ giám sát trả tiền
là chứng minh được "chỗ này tuần trước hỏng, tuần này đã sửa" bằng hai tấm ảnh cùng vị trí.

## 1. Mục tiêu

1. Ghi một lỗi trong dưới 20 giây, khi đang đứng và cầm máy một tay.
2. Ở đợt khảo sát sau, mở đúng lỗi cũ tại đúng vị trí và chụp ảnh đối chứng.
3. Xuất ra PDF cặp ảnh trước/sau đặt cạnh nhau (xem [05-reporting.md](05-reporting.md)).

## 2. Phạm vi

**Trong phạm vi**

1. CRUD `Issue`, gắn nhiều `Capture` vào một `Issue`.
2. Mức độ (`critical` / `major` / `minor`), trạng thái, hạn xử lý.
3. Danh sách lỗi tồn theo `Location`, mang sang đợt sau.
4. Ghép cặp trước/sau và đóng lỗi bằng ảnh đối chứng.
5. Thư viện mô tả lỗi hay dùng, để gõ ít đi.

**Ngoài phạm vi**

1. Giao việc cho người khác, thông báo push. Đây là app ghi nhận, không phải app quản lý công việc.
2. Bình luận nhiều người trên một issue (v2).

## 3. Luồng chính

### 3.1 Ghi lỗi mới

```
Màn hình Capture → chụp xong → thumbnail hiện lên
  → [Gắn lỗi] → sheet:
      • Mô tả (gõ, hoặc chọn từ thư viện cụm hay dùng)
      • Mức độ: [Nghiêm trọng] [Nặng] [Nhẹ]     ← 3 nút to, mặc định "Nặng"
      • Hạn xử lý (tuỳ chọn)
  → Lưu → quay lại camera, sẵn sàng chụp tiếp
```

Sheet phải **quay lại camera**, không quay ra danh sách. Người dùng đang đi một vòng phòng,
mỗi lần bật lại camera tốn gần một giây và phá nhịp làm việc.

Mặc định `severity = .major`: người dùng ghi lỗi vì nó đáng ghi, chọn mặc định "nhẹ" sẽ khiến
tất cả lỗi thành nhẹ vì không ai đổi mặc định.

### 3.2 Ghép cặp trước/sau

```
Đợt khảo sát mới → chọn Location
  → Banner: "3 lỗi tồn từ đợt 12/08"
  → Chọn lỗi → [Chụp ảnh đối chứng]
      → Overlay ảnh cũ mờ 30% lên preview để canh đúng góc
  → Chụp → chọn kết quả: [Đã xử lý] [Chưa xử lý] [Phát sinh thêm]
```

**Overlay ảnh cũ lên preview** là chi tiết nhỏ nhưng quyết định chất lượng biên bản — không có
nó thì hai ảnh chụp lệch góc và cặp trước/sau vô nghĩa.

Cơ chế: `Issue` neo vào `Location` (không phải `Session`), nên cùng một `Location` ở hai đợt
khác nhau vẫn thấy được lỗi của nhau. Đây là lý do `Location` thuộc `Project` trong
[data-model.md](data-model.md).

### 3.3 Đóng lỗi

Chọn "Đã xử lý" thì:

1. Tạo `Issue` mới ở đợt hiện tại, `status = .verified`, mang ảnh đối chứng.
2. Set `oldIssue.resolvedByIssue = newIssue`, `oldIssue.status = .resolved`.
3. **Không sửa, không xoá** `Capture` cũ. Lịch sử là thứ đang bán.

## 4. Thư viện cụm mô tả

Gõ trên điện thoại giữa công trường là chậm. Giữ một danh sách cụm hay dùng, sắp theo tần suất
người dùng đã chọn:

```
"Nứt chân chim trần"   "Thấm chân tường"   "Gạch phồng"
"Sơn không đều"        "Ron gạch hở"       "Cửa cong vênh"
```

1. Seed sẵn ~30 cụm cho lĩnh vực xây dựng/bàn giao căn hộ.
2. Người dùng gõ cụm mới → tự thêm vào thư viện của họ.
3. Sắp theo số lần dùng, cụm mới nhất lên trước khi hoà.
4. Lưu local, đồng bộ qua Firestore (xem [08-auth-sync.md](08-auth-sync.md)).

## 5. Thiết kế kỹ thuật

```swift
@MainActor
final class IssueEditorViewModel: ObservableObject {
    @Published var title: String
    @Published var severity: IssueSeverity
    @Published var dueDate: Date?
    @Published private(set) var suggestions: [PhraseSuggestion]

    func attach(captureIDs: [PersistentIdentifier]) async throws
    func save() async throws -> PersistentIdentifier
}

struct IssuePairing {
    let previous: IssueSnapshot
    let current: IssueSnapshot?
    let outcome: PairingOutcome   // .resolved / .stillOpen / .worsened
}
```

Logic ghép cặp (`IssuePairingService`) nằm trong `Core`, **không import framework**, nhận vào
array snapshot và trả về array `IssuePairing`. Đây là thứ test được dày và là logic dễ sai nhất
trong app.

### Thứ tự ưu tiên upload

`severity` được truyền xuống `UploadKit` làm `priority`:

| Severity | Priority |
|---|---|
| `.critical` | 100 |
| `.major` | 50 |
| `.minor` | 10 |
| Capture không gắn issue | 5 |
| Video (bất kể severity) | trừ 20 |

Video trừ điểm vì nó chiếm băng thông đủ lâu để chặn hàng chục ảnh phía sau. Chi tiết:
[04-upload-engine.md](04-upload-engine.md).

## 6. Constants

```swift
enum IssueDefaults {
    static let severity: IssueSeverity = .major
    static let dueDateOffsetDays: Int = 7
    static let maxCapturesPerIssue: Int = 20
    static let phraseSuggestionCount: Int = 6
    static let overlayOpacity: Double = 0.30
}
```

## 7. Rủi ro đã biết

1. **Location bị xoá/đổi tên giữa hai đợt** → mất neo ghép cặp. `Location` không cho xoá khi
   còn `Issue` mở; đổi `code` thì giữ nguyên `id`, ghi audit log.
2. **Người dùng chụp đối chứng sai vị trí.** Overlay giảm rủi ro, nhưng PDF vẫn phải in kèm
   `Location.code` dưới mỗi ảnh để bên nhận tự kiểm tra được.
3. **Lỗi tồn dồn nhiều đợt.** Sau 3 đợt chưa xử lý, banner đổi màu và PDF có mục riêng
   "Lỗi tồn quá 3 đợt" — đây là thứ giám sát cần để làm việc với thầu.

## 8. Definition of done

1. Ghi một lỗi có ảnh trong dưới 20 giây, đo thật bằng đồng hồ.
2. Đợt 2 mở đúng 3 lỗi tồn của đợt 1 tại cùng Location, offline.
3. Đóng lỗi bằng ảnh đối chứng → `Capture` cũ không đổi một byte, hash kiểm lại vẫn khớp.
4. Zero warning.

## 9. Test

| Test | Loại |
|---|---|
| `IssuePairingService` ghép đúng khi Location có 0 / 1 / n lỗi tồn | unit, `Core` |
| Ghép cặp bỏ qua issue đã `.verified` ở đợt trước | unit |
| Đóng lỗi không mutate `Capture` cũ (so sánh snapshot toàn bộ field) | unit |
| `priority` tính đúng cho 5 tổ hợp severity × kind | unit |
| Xoá Location còn issue mở bị chặn | unit |
| Thư viện cụm sắp đúng theo tần suất, tie-break bằng thời gian | unit |
