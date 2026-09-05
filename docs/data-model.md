# Data model

Tài liệu tham chiếu chung. Mọi feature spec đều trỏ về đây; định nghĩa entity chỉ sống ở
file này, các file khác chỉ mô tả cách dùng.

## 1. Cây quan hệ

```
Project (công trình)
 └ Session (đợt khảo sát: ngày, người khảo sát, ghi chú)
    └ Location (tầng / căn / phòng)
       └ Capture (photo | video | audio)
          └ Issue (mô tả, mức độ, hạn xử lý, trạng thái)
```

`Location` thuộc về `Project`, **không** thuộc `Session`. Một căn hộ tồn tại độc lập với các
lần đi khảo sát; đó là điều kiện để ghép cặp ảnh trước/sau giữa hai đợt
(xem [03-issue-tracking.md](03-issue-tracking.md)).

## 2. Nguyên tắc bất biến

`Capture` **bất biến sau khi tạo**. Sau lần ghi đầu tiên, các trường sau không bao giờ đổi:

`id`, `fileURL`, `sha256`, `capturedAt`, `latitude`, `longitude`, `deviceModel`, `byteSize`, `kind`

Sửa được: `label`, `issues`, `sortIndex`, `uploadState`, `remoteKey`.

Không có API xoá `Capture` khỏi một `Session` đã export. Ẩn khỏi báo cáo thì đặt cờ
`isExcludedFromReport`, và thao tác đó **ghi audit log** (xem [07-security.md](07-security.md)).

## 3. Entity

### Project

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` | `UUID` | |
| `name` | `String` | Tên công trình |
| `address` | `String` | |
| `clientName` | `String` | Chủ đầu tư / bên nhận bàn giao |
| `createdAt` | `Date` | |
| `sessions` | `[Session]` | cascade delete |
| `locations` | `[Location]` | cascade delete |

### Session

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` | `UUID` | |
| `startedAt` / `endedAt` | `Date` / `Date?` | `endedAt` nil = đang mở |
| `surveyorName` | `String` | |
| `note` | `String` | |
| `state` | `SessionState` | `draft → active → closed → exported` |
| `captures` | `[Capture]` | |

`closed` chặn mọi capture mới. `exported` là trạng thái cuối, chỉ đọc.

### Location

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` | `UUID` | |
| `code` | `String` | Mã người dùng gõ: `"A-12.05"`, `"Tầng 3 / P.302"` |
| `kind` | `LocationKind` | `.floor` / `.unit` / `.room` |
| `parent` | `Location?` | Cây tự tham chiếu, tối đa 3 cấp |
| `sortIndex` | `Int` | Thứ tự người dùng kéo thả |

### Capture

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` | `UUID` | |
| `kind` | `CaptureKind` | `.photo` / `.video` / `.audio` |
| `fileURL` | `URL` | Tương đối với app container, **không lưu absolute path** |
| `sha256` | `String` | Hash của **plaintext**, tính trước khi ghi DB |
| `byteSize` | `Int64` | |
| `capturedAt` | `Date` | |
| `latitude` / `longitude` | `Double?` | **Nullable** — hầm gửi xe không có GPS |
| `horizontalAccuracy` | `Double?` | Để PDF ghi được "±35m" thay vì giả vờ chính xác |
| `deviceModel` | `String` | |
| `duration` | `TimeInterval?` | video/audio |
| `measurement` | `Measurement?` | Số đo từ BLE, xem [06-device-link.md](06-device-link.md) |
| `uploadState` | `UploadState` | |
| `remoteKey` | `String?` | Object key trên R2 sau khi synced |
| `isExcludedFromReport` | `Bool` | |

`fileURL` lưu **đường dẫn tương đối**. App container thay đổi UUID sau mỗi lần cài lại/khôi
phục từ backup; lưu absolute path là cách chắc chắn nhất để mất toàn bộ media của người dùng.

### Issue

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` | `UUID` | |
| `title` | `String` | |
| `detail` | `String` | |
| `severity` | `IssueSeverity` | `.critical` / `.major` / `.minor` |
| `status` | `IssueStatus` | `.open → .inProgress → .resolved → .verified` |
| `dueDate` | `Date?` | |
| `location` | `Location` | Neo vào Location, không phải Session |
| `captures` | `[Capture]` | Nhiều ảnh cho một lỗi |
| `resolvedByIssue` | `Issue?` | Trỏ tới issue ở đợt sau xác nhận đã xử lý |

`severity` ảnh hưởng **thứ tự upload**: `.critical` lên trước (xem
[04-upload-engine.md](04-upload-engine.md)).

## 4. `UploadState`

```
pending → uploading → synced
             ↓  ↑
           failed
```

| State | Nghĩa |
|---|---|
| `pending` | Đã ghi file + hash, chưa enqueue |
| `uploading` | Có ít nhất một part đang bay |
| `failed` | Đã hết retry budget, chờ người dùng bấm thử lại |
| `synced` | Server đã `complete`, ETag khớp |

`failed` **không** phải trạng thái cuối và không bao giờ tự xoá file local. File local chỉ
được xoá khi `synced` **và** người dùng chủ động dọn dẹp.

## 5. Schema versioning

SwiftData `VersionedSchema` + `SchemaMigrationPlan` từ **ngay phiên bản đầu tiên**, kể cả khi
chỉ có một version. Thêm migration plan sau khi đã có dữ liệu thật trên máy người dùng là
việc không làm được sạch.

Mỗi lần đổi schema:

1. Tạo `SchemaV{n}` mới, giữ nguyên `SchemaV{n-1}`.
2. Khai báo `MigrationStage` — `.lightweight` nếu chỉ thêm field optional, `.custom` nếu đổi
   ý nghĩa dữ liệu.
3. Test migration bằng một store fixture của version cũ, không test bằng store rỗng.

## 6. Concurrency

SwiftData `ModelContext` không `Sendable`. Ba quy tắc:

1. UI đọc/ghi qua `@MainActor` context của `ModelContainer`.
2. Ghi từ background (hash xong, upload xong) đi qua một `@ModelActor` riêng.
3. **Không** truyền `PersistentModel` qua actor boundary — truyền `PersistentIdentifier` rồi
   fetch lại ở phía kia.
