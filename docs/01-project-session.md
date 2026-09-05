# 01 — Công trình, đợt khảo sát, vị trí

Module: `App/Features/Projects`, `Packages/Core`, `Packages/Persistence`

## 1. Mục tiêu

Cho người dùng dựng được cây `Project → Session → Location` nhanh hơn cầm sổ, **hoàn toàn
offline**, và điều hướng được trong đó bằng một tay khi đang đứng giữa công trường.

## 2. Phạm vi

**Trong phạm vi**

1. CRUD `Project`, `Session`, `Location`.
2. Cây `Location` tối đa 3 cấp (`floor → unit → room`).
3. Tạo nhanh hàng loạt Location theo mẫu ("Tầng 1–20, mỗi tầng 4 căn").
4. Nhân bản cây Location từ Session/Project khác.
5. Đóng session (`closed`) và mở lại (chỉ khi chưa `exported`).

**Ngoài phạm vi**

1. Chia sẻ project cho nhiều người dùng (v2 — xem [08-auth-sync.md](08-auth-sync.md)).
2. Import cây từ file Excel/CAD.

## 3. Luồng người dùng

```
Danh sách Project
  → [+] Tạo Project (tên, địa chỉ, chủ đầu tư)
  → Chi tiết Project: tab [Đợt khảo sát] [Sơ đồ vị trí]
      → [+] Bắt đầu đợt khảo sát (tên người khảo sát, ghi chú)
      → Màn hình khảo sát: danh sách Location kèm badge số capture / số issue
          → Chọn Location → mở Capture (feature 02)
      → [Kết thúc đợt] → state = closed
```

Màn hình khảo sát là màn hình người dùng ở lâu nhất. Ba yêu cầu:

1. **Một tay, ngón cái.** Nút mở camera nằm nửa dưới màn hình.
2. **Badge cập nhật tức thì**, không đợi upload — số liệu đọc từ local store.
3. **Không có spinner chặn.** Không thao tác nào trong feature này chạm mạng.

## 4. Tạo nhanh Location theo mẫu

Đây là tính năng tiết kiệm thời gian rõ nhất và là thứ đầu tiên người dùng thật sẽ khen.

Input: tiền tố, dải tầng, số căn mỗi tầng, mẫu mã căn.

```
Tầng: 1...20        Căn/tầng: 4        Mẫu: "{floor}-{unit:02}"
→ 1-01, 1-02, 1-03, 1-04, 2-01, ... 20-04   (80 Location)
```

Quy tắc:

1. Sinh trong một transaction duy nhất, không ghi từng cái một.
2. **Preview trước khi commit** — hiện 5 mã đầu, 3 mã cuối và tổng số.
3. Mã trùng trong cùng Project thì chặn, hiện đúng mã nào trùng.
4. Giới hạn cứng 2000 Location một lần để không có ai vô tình tạo 1 triệu record.

## 5. Thiết kế kỹ thuật

### ViewModel

```swift
@MainActor
final class SurveySessionViewModel: ObservableObject {
    @Published private(set) var locations: [LocationRow]
    @Published private(set) var state: SessionState

    func startSession(surveyor: String, note: String) async throws
    func closeSession() async throws
    func generateLocations(_ spec: LocationTemplateSpec) async throws -> LocationTemplatePreview
    func commitLocations(_ preview: LocationTemplatePreview) async throws
}
```

`LocationRow` là struct phẳng cho View (`id`, `code`, `captureCount`, `openIssueCount`,
`pendingUploadCount`) — View không cầm `PersistentModel`.

### Đếm badge

Đừng fetch toàn bộ `Capture` để đếm. Dùng `fetchCount` với `#Predicate` theo `locationID`, và
gộp một lần cho cả màn hình thay vì mỗi row tự query — 80 Location × 2 query mỗi lần scroll là
cách chắc chắn để list bị giật.

### Constants

Mọi giới hạn nằm trong một chỗ:

```swift
enum LocationTemplateLimits {
    static let maxGeneratedPerBatch: Int = 2000
    static let maxDepth: Int = 3
    static let previewHeadCount: Int = 5
    static let previewTailCount: Int = 3
}
```

## 6. Rủi ro đã biết

1. **Đóng session nhầm.** `closed` chặn capture mới; phải có nút mở lại và hiện rõ trạng thái
   ở header, không giấu trong menu.
2. **Xoá Project = xoá vài GB media.** Cascade delete phải hỏi lại kèm số liệu cụ thể
   ("3 đợt, 412 ảnh, 2.1 GB, 87 file chưa upload"), không phải "Bạn có chắc không?".
3. **Xoá khi còn file `pending`** thì dữ liệu mất vĩnh viễn. Chặn, không cảnh báo suông.

## 7. Definition of done

1. Tạo được Project → Session → 80 Location → mở Capture, **ở chế độ máy bay**, không lỗi.
2. Danh sách 500 Location scroll 60fps trên máy thật.
3. Kill app giữa lúc đang tạo Location hàng loạt → mở lại không có record nửa vời.
4. Zero warning, `swiftlint` sạch.

## 8. Test

| Test | Loại |
|---|---|
| `LocationTemplateSpec` sinh đúng mã cho các mẫu biên (1 tầng, 1 căn, mã trùng) | unit, `Core` |
| Chặn tạo quá `maxGeneratedPerBatch` | unit |
| Chặn tạo Location cấp 4 | unit |
| Session `closed` từ chối `addCapture` | unit |
| Cascade delete Project xoá hết file trên disk, không để orphan | integration, `Persistence` |
| Migration từ `SchemaV1` với fixture có sẵn 100 Location | integration |
