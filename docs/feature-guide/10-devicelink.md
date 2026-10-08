# F10 — DeviceLink (BLE meters)

- F10 · 18h · skeleton guide — full code is added when this feature starts.

## Contents

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain — DeviceLink types](#1-domain--devicelink-types)
4. [2. Fake data — Fake device link](#2-fake-data--fake-device-link)
5. [3. View models — Wire pairing and overlay](#3-view-models--wire-pairing-and-overlay)
6. [4. Real data — BLE and mock peripheral](#4-real-data--ble-and-mock-peripheral)
7. [Tests (after the feature works)](#tests-after-the-feature-works)
8. [Feature done](#feature-done)

## Overview

- **Goal:** DeviceLink (BLE meters) end to end: Domain → fake data → view models → real data → tests.
- **Demo:** laser reading from the macOS mock peripheral shows on the camera; capture never waits.
- **Spec:** [06](../feature-docs/01-field-work.md#06-devicelink-ble-measuring-tools)
- **Starts from:** the skeleton screens (~30% of Figma) that read `Core/Fakes/FakeData.swift`.
- **Fakes:** only in `SiteLog/Data/Fakes/`, registered in `AppDependencies`; the dev menu seeds / clears them through `FakeDevDataActions`.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--devicelink-types) | Domain | 1h | not start | DeviceLink types |
| [2](#2-fake-data--fake-device-link) | Fake data | 1h | not start | Fake device link |
| [3](#3-view-models--wire-pairing-and-overlay) | View models | 3h | not start | Wire pairing and overlay |
| [4](#4-real-data--ble-and-mock-peripheral) | Real data | 13h | not start | BLE and mock peripheral |

<details open>
<summary><b>Order</b></summary>

- Steps run top to bottom; the app runs after every step.
- Real data changes only registrations in `AppDependencies`, never views or view models.
- Tests come last, once the feature works end to end.

</details>

## Target structure

```text
SiteLog/
├── Domain/DeviceLink/        # 1: DeviceReading, DeviceLink protocol
├── Data/Fakes/               # 2: FakeDeviceLink (scripted readings)
├── DataSources/DeviceLink/   # 4: DeviceLinkManager (actor), Profiles/
Tools/MockPeripheral/         # 4: macOS BLE simulator
SiteLog/Presentation/
├── Settings/Devices/         # 3: S2 pairing
└── Capture/Camera/           # 3: measurement overlay, status dot
```

## 1. Domain — DeviceLink types

| File | Holds |
|---|---|
| `Domain/DeviceLink/` | `DeviceReading`, `DeviceLink` protocol (scan, connect, readings stream) |

## 2. Fake data — Fake device link

| File | Holds |
|---|---|
| `SiteLog/Data/Fakes/FakeDeviceLink.swift` | Emits 3.42 m every few seconds; a nearby list |
| `SiteLog/App/AppDependencies.swift` | Registers the fake |

## 3. View models — Wire pairing and overlay

| Skeleton folder | View model work |
|---|---|
| `Presentation/Settings/Devices/` | S2: my devices, nearby, pair |
| `Presentation/Capture/Camera/` | Reading overlay and status dot |

#### Steps

1. Add `<Screen>ViewModel.swift` next to the view: `@MainActor @Observable`, use cases through `@Injected`.
2. In the view, replace `FakeData…` with view-model state; keep the layout (visual finish is F16).
3. Loading, empty (`DSEmptyState`) and error states; previews for each.
4. Delete this feature's `Fake*` types from `Core/Fakes/FakeData.swift` once nothing uses them.

## 4. Real data — BLE and mock peripheral

- **Goal:** scan → connect → read a laser or moisture meter; macOS mock for CI.
- **Spec:** [06](../feature-docs/01-field-work.md#06-devicelink-ble-measuring-tools)

| File | Holds |
|---|---|
| `DeviceLink/DeviceLinkManager.swift` | Actor around `CBCentralManager` |
| `DeviceLink/Profiles/` | One file per vendor; pure `parse` |
| `Tools/MockPeripheral/` | Scripts values, disconnects, garbage bytes |

#### Steps

1. Split when you start (manager · profiles · mock).
2. Never blocks capture.

## Tests (after the feature works)

**4. Real data — BLE and mock peripheral**

- Vendor `parse` on real bytes
- Reconnect backoff capped
- Full flow against the mock

## Feature done

| Check | How |
|---|---|
| Demo | BLE mock reading on the camera |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F10 steps ticked |

