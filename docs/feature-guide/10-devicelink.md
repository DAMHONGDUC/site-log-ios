# F10 — DeviceLink (BLE meters)

<dl><dd>

- F10 · 18h · skeleton guide — full code is added when this feature starts.

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain — DeviceLink types](#1-domain--devicelink-types)
4. [2. Fake data — Device link on scripted readings](#2-fake-data--device-link-on-scripted-readings)
5. [3. View models — Wire pairing and overlay](#3-view-models--wire-pairing-and-overlay)
6. [4. Real data — BLE and mock peripheral](#4-real-data--ble-and-mock-peripheral)
7. [Tests (after the feature works)](#tests-after-the-feature-works)
8. [Feature done](#feature-done)

</dd></dl>

## Overview

<dl><dd>

- **Goal:** DeviceLink (BLE meters) end to end: Domain → fake data → view models → real data → tests.
- **Demo:** laser reading from the macOS mock peripheral shows on the camera; capture never waits.
- **Spec:** [06](../feature-docs/01-field-work.md#06-devicelink-ble-measuring-tools)
- **Starts from:** the skeleton screens (~30% of Figma) that read `App/Fakes/FakeData.swift`.
- **No fake repository:** the fake-data step writes the real implementation on in-memory values, registered once in `AppDependencies`; the real-data step swaps its insides, never the type. The dev menu seeds / clears it through `AppDevDataActions`; test doubles live only in test targets.
- **File tags:** <b class="tag-new">New</b> create the file · <b class="tag-edit">Edit</b> change only the part shown.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--devicelink-types) | Domain | 1h | not start | DeviceLink types |
| [2](#2-fake-data--device-link-on-scripted-readings) | Fake data | 1h | not start | `BLEDeviceLink` on scripted readings |
| [3](#3-view-models--wire-pairing-and-overlay) | View models | 3h | not start | Wire pairing and overlay |
| [4](#4-real-data--ble-and-mock-peripheral) | Real data | 13h | not start | BLE and mock peripheral |

<details open>
<summary><strong>Order</strong></summary>
<dl><dd>

- Steps run top to bottom; the app runs after every step.
- Real data changes only registrations in `AppDependencies`, never views or view models.
- Tests come last, once the feature works end to end.

</dd></dl>
</details>

</dd></dl>

## Target structure

<dl><dd>

```text
Packages/
├── DomainLayer/Sources/DomainLayer/DeviceLink/                   # 1: DeviceReading, DeviceLink protocol
├── DataLayer/Sources/DataLayer/Repositories/BLEDeviceLink.swift  # 2: scripted readings · 4: Bluetooth
├── DataLayer/Sources/DataLayer/Repositories/BLEDeviceLink.swift  # 4: Domain DeviceLink over DeviceLinkManager
└── Infrastructure/Sources/Infrastructure/DeviceLink/             # 4: DeviceLinkManager (actor), Profiles/
SiteLog/Presentation/
├── Settings/Devices/                                             # 3: S2 pairing
└── Capture/Camera/                                               # 3: measurement overlay, status dot
Tools/MockPeripheral/                                             # 4: macOS BLE simulator
```

</dd></dl>

## 1. Domain — DeviceLink types

<dl><dd>

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Packages/DomainLayer/Sources/DomainLayer/DeviceLink/` | `DeviceReading`, `DeviceLink` protocol (scan, connect, readings stream) |

</dd></dl>

## 2. Fake data — Device link on scripted readings

<dl><dd>

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Packages/DataLayer/Sources/DataLayer/Repositories/BLEDeviceLink.swift` | Emits 3.42 m every few seconds and a nearby list until step 4 |
| <b class="tag-edit">Edit</b> | `SiteLog/App/AppDependencies.swift` | Registers it once; the real-data step keeps this registration |

</dd></dl>

## 3. View models — Wire pairing and overlay

<dl><dd>

| Action | Skeleton folder | View model work |
|---|---|---|
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Settings/Devices/` | S2: my devices, nearby, pair |
| <b class="tag-edit">Edit</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Capture/Camera/` | Reading overlay and status dot |

#### Steps

<dl><dd>

1. Add `<Screen>ViewModel.swift` next to the view: `@MainActor @Observable`, use cases through `@Injected`.
2. In the view, replace `FakeData…` with view-model state; keep the layout (visual finish is F16).
3. Loading, empty (`SDEmptyState`) and error states; previews for each.
4. Delete this feature's `Fake*` types from `App/Fakes/FakeData.swift` once nothing uses them.

</dd></dl>

</dd></dl>

## 4. Real data — BLE and mock peripheral

<dl><dd>

- **Goal:** scan → connect → read a laser or moisture meter; macOS mock for CI.
- **Spec:** [06](../feature-docs/01-field-work.md#06-devicelink-ble-measuring-tools)

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Packages/Infrastructure/Sources/Infrastructure/DeviceLink/DeviceLinkManager.swift` | Actor around `CBCentralManager`; own reading records |
| <b class="tag-new">New</b> | `Infrastructure/DeviceLink/Profiles/` | One file per vendor; pure `parse` |
| <b class="tag-replace">Replace</b> | `Packages/DataLayer/Sources/DataLayer/Repositories/BLEDeviceLink.swift` | Same type, now implements Domain `DeviceLink` over `DeviceLinkManager`; maps records to `DeviceReading` |
| <b class="tag-edit">Edit</b> | `SiteLog/App/AppDependencies.swift` | Register `DeviceLinkManager` and pass it to `BLEDeviceLink` |
| <b class="tag-new">New</b> | `Tools/MockPeripheral/` | Scripts values, disconnects, garbage bytes |

#### Steps

<dl><dd>

1. Split when you start (manager · profiles · adapter · mock).
2. Never blocks capture.

</dd></dl>

</dd></dl>

## Tests (after the feature works)

<dl><dd>

**4. Real data — BLE and mock peripheral**

- Vendor `parse` on real bytes
- Reconnect backoff capped
- Full flow against the mock

</dd></dl>

## Feature done

<dl><dd>

| Check | How |
|---|---|
| Demo | BLE mock reading on the camera |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F10 steps ticked |

</dd></dl>
