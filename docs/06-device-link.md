# 06 — DeviceLink: BLE measuring tools

Module: `Packages/DeviceLink`

Targets real hardware: laser distance meters (Bosch GLM, Leica Disto) and wall moisture meters.
All advertise over BLE; today users read the display and retype the number.

## Goal

Scan → connect → read measurement → attach directly to a `Capture`.

Architecture mirrors the real stack: **BLE for control and small values, WiFi for large files.**
This is why DeviceLink and [UploadKit](04-upload-engine.md) are separate packages.

## Scope

| In | Out |
|---|---|
| Scan filtered by service UUID, with RSSI | Writing configuration to devices |
| Connect, discover, subscribe to notify | File transfer over BLE |
| Parse into `Measurement` | Continuous background scanning |
| Attach to the in-flight capture or issue | |
| Auto-reconnect to paired devices | |
| macOS mock peripheral | |

## Structure

```
DeviceLink/
  DeviceLinkManager.swift        # actor wrapping CBCentralManager
  DeviceProfile.swift            # one profile per vendor
  Profiles/{BoschGLM,LeicaDisto,GenericMoisture}Profile.swift
  MeasurementParser.swift        # pure bytes → Measurement
  Models/Measurement.swift
```

```swift
public protocol DeviceProfile: Sendable {
    static var serviceUUID: CBUUID { get }
    static var notifyCharacteristicUUID: CBUUID { get }
    static var displayName: String { get }
    static func parse(_ data: Data) throws -> Measurement
}

public struct Measurement: Sendable, Codable, Equatable {
    public let value: Double
    public let unit: MeasurementUnit      // .meter / .millimeter / .percentMoisture
    public let kind: MeasurementKind      // .distance / .area / .moisture
    public let measuredAt: Date
    public let deviceName: String
}
```

- Adding a vendor is one file, with no change to connection code.
- `parse` is pure over `Data`, testable against byte arrays captured from real hardware.

## CoreBluetooth lifecycle

The four things most often gotten wrong:

| # | Rule | Symptom if broken |
|---|---|---|
| 1 | Hold a strong reference to `CBPeripheral` | It deallocates mid-connect; `didConnect` never fires |
| 2 | Issue no commands before `.poweredOn` | Silently dropped scans |
| 3 | Check `error` on both discover callbacks | Surfaces later as "no data" |
| 4 | Reconnect via `retrievePeripherals(withIdentifiers:)` | Slow rescan on every launch |

```
poweredOff → poweredOn → scanning → connecting → discovering → ready
                              ↑                                  │
                              └──────── disconnected ←───────────┘
```

- `DeviceLinkManager` is an `actor`; CoreBluetooth callbacks hop in via `Task`. No
  `@unchecked Sendable` shortcuts.
- `disconnected` is not inherently an error — these meters power off when idle. Reconnect backoff
  is independent of upload retry.

## macOS mock peripheral

```
Tools/MockPeripheral/
  main.swift                   # CBPeripheralManager advertising a fake service
  ScriptedMeasurements.swift   # scripted value sequences
```

Scripts what is hard to produce in the field: invalid values, mid-session disconnects, malformed
payloads, garbage bytes. Also what makes CI possible.

## UX rules

- Measurement overlays the camera preview, readable at arm's length.
- Shutter freezes the current measurement into the `Capture`; no measurement still captures.
- Connection status is a colored dot, not a banner. Disconnection greys it with **no alert**.
- **DeviceLink never blocks capture.** It is an accessory.

```swift
enum DeviceLinkConstants {
    static let scanTimeout: TimeInterval = 15
    static let connectTimeout: TimeInterval = 10
    static let reconnectBaseDelay: TimeInterval = 2
    static let reconnectMaxDelay: TimeInterval = 60
    static let minimumRSSI: Int = -85
    static let measurementStaleAfter: TimeInterval = 30
    static let backgroundDisconnectDelay: TimeInterval = 300
    static let pairedDeviceIDsKey: String = "devicelink.paired.identifiers"
}
```

Measurements older than `measurementStaleAfter` are not attached — the user has moved rooms, and
attaching the previous reading corrupts data silently.

## Known risks

| Risk | Handling |
|---|---|
| No hardware to verify byte formats | Start on the mock; ship a "generic" profile showing raw bytes for field comparison |
| Bluetooth permission denied | Feature hides itself; the rest of the app is unaffected |
| Battery drain | No background scanning; stop after `scanTimeout`; disconnect after `backgroundDisconnectDelay` |
| App Store review of the usage string | Describe the actual purpose, not a generic line |

## Definition of done

- Connects to the macOS mock, reads a sequence, attaches to a `Capture`.
- Killing the mock: no crash, dot greys, capture still works.
- App kill → relaunch auto-reconnects a paired device within 10 s.
- Denied Bluetooth: every other feature works.
- Zero warnings; builds independently.

## Tests

| Test | Kind |
|---|---|
| `BoschGLMProfile.parse` against captured real byte arrays | unit, pure |
| `parse` with empty / truncated / bad-checksum payloads throws precisely | unit |
| Unit conversion (m ↔ mm ↔ ft) | unit |
| Measurement past `measurementStaleAfter` is not attached | unit, injected clock |
| `disconnected` during `discovering` returns to `scanning`, no leaked tasks | unit |
| Reconnect backoff never exceeds `reconnectMaxDelay` | unit |
| Full flow against the mock peripheral | integration |
