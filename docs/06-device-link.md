# 06 — DeviceLink: máy đo qua BLE

Module: `Packages/DeviceLink`

Vùng tự viết thứ ba. Neo vào **thiết bị có thật**: máy đo khoảng cách laser (Bosch GLM, Leica
Disto) và máy đo ẩm tường — đều phát BLE, thợ dùng hàng ngày, hiện phải đọc số trên máy rồi
gõ tay vào app.

## 1. Mục tiêu

Scan → kết nối → đọc số đo → **gắn thẳng vào `Capture`**, không gõ tay.

Kiến trúc đúng chuẩn thật: **BLE để điều khiển và đọc giá trị nhỏ, WiFi để truyền file lớn.**
Đây là câu trả lời cho câu hỏi phỏng vấn "tại sao không truyền ảnh qua BLE" và là lý do
DeviceLink và [UploadKit](04-upload-engine.md) là hai package tách rời.

## 2. Phạm vi

**Trong phạm vi**

1. Scan thiết bị, lọc theo service UUID, hiện RSSI.
2. Kết nối, discover service/characteristic, subscribe notify.
3. Parse giá trị đo → `Measurement` (giá trị, đơn vị, loại, thời điểm).
4. Gắn số đo vào `Capture` đang chụp hoặc `Issue` đang ghi.
5. Tự kết nối lại thiết bị đã ghép đôi khi vào tầm.
6. Mock peripheral trên macOS để phát triển và test khi chưa có máy thật.

**Ngoài phạm vi**

1. Ghi cấu hình xuống thiết bị. Chỉ đọc.
2. Truyền file qua BLE. Sai kiến trúc, và chậm tới mức vô dụng.
3. Background BLE scanning liên tục (tốn pin, và cần lý do chính đáng khi review App Store).

## 3. Kiến trúc

```
DeviceLink/
  DeviceLinkManager.swift        # actor, quản lý CBCentralManager
  DeviceProfile.swift            # protocol: mỗi hãng máy một profile
  Profiles/
    BoschGLMProfile.swift
    LeicaDistoProfile.swift
    GenericMoistureProfile.swift
  MeasurementParser.swift        # bytes → Measurement, thuần
  Models/Measurement.swift
```

```swift
public protocol DeviceProfile: Sendable {
    static var serviceUUID: CBUUID { get }
    static var notifyCharacteristicUUID: CBUUID { get }
    static var displayName: String { get }
    static func parse(_ data: Data) throws -> Measurement
}
```

Tách profile ra khỏi manager là chỗ đáng nói nhất: thêm một hãng máy mới = thêm một file, không
đụng vào code kết nối. Và `parse` là hàm **thuần trên `Data`**, nên test được bằng byte array
đã capture từ máy thật, không cần thiết bị.

```swift
public struct Measurement: Sendable, Codable, Equatable {
    public let value: Double
    public let unit: MeasurementUnit      // .meter / .millimeter / .percentMoisture
    public let kind: MeasurementKind      // .distance / .area / .moisture
    public let measuredAt: Date
    public let deviceName: String
}
```

## 4. Vòng đời CoreBluetooth

Bốn thứ dễ làm sai nhất, viết ra để không phải học lại:

1. **Giữ strong reference tới `CBPeripheral`.** Không giữ thì nó bị dealloc giữa lúc kết nối và
   `didConnect` không bao giờ về. Đây là bug BLE phổ biến nhất.
2. **Không gọi gì trước khi `centralManagerDidUpdateState` báo `.poweredOn`.** Queue lại lệnh
   scan, flush khi state sẵn sàng.
3. **`didDiscoverServices` và `didDiscoverCharacteristics` là hai bước riêng**, mỗi bước phải
   check `error` — bỏ qua error ở đây thì lỗi hiện ra muộn dưới dạng "không có dữ liệu".
4. **Kết nối lại bằng `retrievePeripherals(withIdentifiers:)`** sau relaunch, không scan lại từ
   đầu. Lưu `identifier` (UUID) của thiết bị đã ghép đôi vào `UserDefaults`.

`DeviceLinkManager` là `actor`; callback của CoreBluetooth về trên queue riêng và được đẩy vào
actor bằng `Task`. Không dùng `@unchecked Sendable` để đi tắt qua chỗ này.

### State machine

```
poweredOff → poweredOn → scanning → connecting → discovering → ready
                              ↑                                  │
                              └──────── disconnected ←───────────┘
```

`disconnected` không tự động là lỗi — thiết bị tự tắt sau vài phút không dùng là hành vi bình
thường của máy đo. Reconnect có backoff riêng, không dùng chung với upload.

## 5. Mock peripheral trên macOS

Để phát triển và test khi chưa có thiết bị thật, và để CI chạy được:

```
Tools/MockPeripheral/          # SwiftPM executable, macOS
  main.swift                   # CBPeripheralManager quảng bá service giả
  ScriptedMeasurements.swift   # phát chuỗi giá trị theo kịch bản
```

Chạy trên MacBook, app trên iPhone thật kết nối vào. Cho phép script các kịch bản khó gặp
ngoài đời: giá trị lỗi, ngắt kết nối giữa chừng, gửi payload sai định dạng, gửi rác.

Đây cũng là câu trả lời tốt trong phỏng vấn cho "làm sao test BLE" — phần lớn người làm BLE
không có câu trả lời cho câu này.

## 6. UX

1. Số đo hiện **overlay ngay trên preview camera**, cỡ lớn, đọc được khi cầm xa tay.
2. Bấm chụp → số đo hiện tại đóng băng vào `Capture`. Không có số đo thì vẫn chụp bình thường.
3. Chỉ báo kết nối là một chấm màu ở góc, không phải banner chiếm chỗ.
4. Mất kết nối giữa chừng → chấm chuyển xám, **không hiện alert**. Người dùng đang chụp, đừng
   chặn họ vì một tính năng phụ trợ.

Nguyên tắc: **DeviceLink không bao giờ được chặn capture.** Nó là tiện ích cộng thêm.

## 7. Constants

```swift
enum DeviceLinkConstants {
    static let scanTimeout: TimeInterval = 15
    static let connectTimeout: TimeInterval = 10
    static let reconnectBaseDelay: TimeInterval = 2
    static let reconnectMaxDelay: TimeInterval = 60
    static let minimumRSSI: Int = -85
    static let measurementStaleAfter: TimeInterval = 30
    static let pairedDeviceIDsKey: String = "devicelink.paired.identifiers"
}
```

Số đo cũ hơn `measurementStaleAfter` **không được gắn vào `Capture`** — người dùng đã đi sang
phòng khác, gắn số đo của phòng trước vào là làm hỏng dữ liệu một cách âm thầm.

## 8. Rủi ro đã biết

1. **Không có máy thật để verify format.** Bắt đầu bằng mock, và cho phép profile "generic":
   hiện raw bytes để người dùng/dev đối chiếu với màn hình máy khi có thiết bị.
2. **Quyền Bluetooth bị từ chối** → toàn bộ feature ẩn đi, app vẫn dùng bình thường.
3. **Pin.** Không scan nền, dừng scan sau `scanTimeout`, ngắt kết nối khi app vào background quá
   5 phút.
4. **App Store review** hỏi về `NSBluetoothAlwaysUsageDescription` — mô tả đúng mục đích, đừng
   viết chung chung.

## 9. Definition of done

1. Kết nối được mock peripheral trên macOS, đọc được chuỗi giá trị, gắn vào `Capture`.
2. Tắt mock giữa chừng → app không crash, chấm chuyển xám, chụp vẫn chạy.
3. Kill app → mở lại → tự reconnect thiết bị đã ghép đôi trong vòng 10 giây.
4. Từ chối quyền Bluetooth → app chạy đủ mọi feature khác.
5. Zero warning, `DeviceLink` build độc lập.

## 10. Test

| Test | Loại |
|---|---|
| `BoschGLMProfile.parse` trên byte array thật đã capture | unit, thuần |
| `parse` với payload rỗng / ngắn / sai checksum → throw đúng lỗi, không crash | unit |
| Đổi đơn vị (m ↔ mm ↔ ft) quy đổi đúng | unit |
| Số đo quá `measurementStaleAfter` không được gắn vào Capture | unit, inject clock |
| State machine: `disconnected` khi đang `discovering` → về `scanning`, không rò task | unit |
| Reconnect backoff không vượt `reconnectMaxDelay` | unit |
| Full flow với mock peripheral | integration, manual + script |
