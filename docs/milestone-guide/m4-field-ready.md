# M4 — Field-ready · TestFlight #2

- M4 — Field-ready · TestFlight #2 · 68h · skeleton guide.

## Contents

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [P48 · Plans, checklists, DeviceLink, diagnostics contract](#p48--plans-checklists-devicelink-diagnostics-contract)
4. [P49 · Floor plan import and storage](#p49--floor-plan-import-and-storage)
5. [P50 · Pin coordinates and persistence](#p50--pin-coordinates-and-persistence)
6. [P51 · Checklist templates and results](#p51--checklist-templates-and-results)
7. [P52 · DeviceLink and BLE mock](#p52--devicelink-and-ble-mock)
8. [P53 · Storage, cleanup, diagnostic bundle](#p53--storage-cleanup-diagnostic-bundle)
9. [P54 · Firebase Crashlytics](#p54--firebase-crashlytics)
10. [P55 · Plans UI](#p55--plans-ui)
11. [P56 · Template picker, K2 checklist run](#p56--template-picker-k2-checklist-run)
12. [P57 · Measurement overlay, device pairing](#p57--measurement-overlay-device-pairing)
13. [P58 · Storage screen, bundle export](#p58--storage-screen-bundle-export)
14. [P59 · Real logic, Instruments, TestFlight #2](#p59--real-logic-instruments-testflight-2)
15. [Milestone done](#milestone-done)

## Overview

- **Goal:** floor-plan pins, checklists, BLE measuring (mock), diagnostics and crash reporting; ship TestFlight #2.
- **Demo:** pins on a real floor plan, checklists, BLE mock, diagnostics.
- **Specs:** [11](../feature-docs/01-field-work.md#11-floor-plans-and-issue-pins), [13](../feature-docs/01-field-work.md#13-checklist-templates), [06](../feature-docs/01-field-work.md#06-devicelink-ble-measuring-tools), [09](../feature-docs/05-platform.md#09-diagnostics-and-observability)
- **Status:** skeleton — parts, files, order, tests. Full, tested code is added when this milestone starts, built on the real code from the milestone before.

| Part | Track | Hours | Status | What |
|---|---|---|---|---|
| [P48](#p48--plans-checklists-devicelink-diagnostics-contract) | `Contract` | 3h | not start | Plans, checklists, DeviceLink, diagnostics contract |
| [P49](#p49--floor-plan-import-and-storage) | `Logic` | 6h | not start | Floor plan import and storage |
| [P50](#p50--pin-coordinates-and-persistence) | `Logic` | 4h | not start | Pin coordinates and persistence |
| [P51](#p51--checklist-templates-and-results) | `Logic` | 5h | not start | Checklist templates and results |
| [P52](#p52--devicelink-and-ble-mock) | `Logic` | 14h | not start | DeviceLink and BLE mock |
| [P53](#p53--storage-cleanup-diagnostic-bundle) | `Logic` | 6h | not start | Storage, cleanup, diagnostic bundle |
| [P54](#p54--firebase-crashlytics) | `Logic` | 3h | not start | Firebase Crashlytics |
| [P55](#p55--plans-ui) | `UI` | 8h | not start | Plans UI |
| [P56](#p56--template-picker-k2-checklist-run) | `UI` | 6h | not start | Template picker, K2 checklist run |
| [P57](#p57--measurement-overlay-device-pairing) | `UI` | 4h | not start | Measurement overlay, device pairing |
| [P58](#p58--storage-screen-bundle-export) | `UI` | 3h | not start | Storage screen, bundle export |
| [P59](#p59--real-logic-instruments-testflight-2) | `Join` | 6h | not start | Real logic, Instruments, TestFlight #2 |

### Order

- P48 contract first.
- Logic P49–P54 and UI P55–P58 in parallel.
- P59 joins + Instruments + TestFlight. P52 is over 8h: split it.

## Target structure

```text
Packages/
├── Plans/                    # P49–P50: PDFKit + CATiledLayer, tile cache
├── DeviceLink/               # P52: DeviceProfile, DeviceLinkManager (actor)
└── Domain/…/Plans/, Checklists/, DeviceLink/, Diagnostics/   # P48
Tools/MockPeripheral/         # P52: macOS BLE simulator
SiteLog/Presentation/
├── Plans/PlanList/, PlanViewer/, PinPreview/, PlanImport/     # P55
├── Checklists/TemplatePicker/, ChecklistRun/                  # P56
├── Settings/Devices/                                          # P57
└── Diagnostics/Storage/                                       # P58
```

## P48 · Plans, checklists, DeviceLink, diagnostics contract

- **Goal:** entities and protocols with fakes.

| File | Holds |
|---|---|
| `Domain/Plans/` | `PlanSheet`, pin as `NormalizedPoint` |
| `Domain/Checklists/` | Template, item, run, result |
| `Domain/DeviceLink/` | `DeviceReading`, link protocol |
| `Domain/Diagnostics/` | Snapshot of integrity + flags |

### Tests

- Fakes drive every M4 screen

## P49 · Floor plan import and storage

- **Goal:** import PDF/image plans, hashed, tiled on demand.
- **Spec:** [11](../feature-docs/01-field-work.md#11-floor-plans-and-issue-pins)

### Steps

1. Multi-page PDF → one `PlanSheet` per chosen page.
2. Reject encrypted / oversized files with a reason.

### Tests

- Oversized and encrypted imports rejected
- A0 peak memory under 150 MB

## P50 · Pin coordinates and persistence

- **Goal:** one pin per issue in 0…1 coordinates; moves audited.
- **Spec:** [11](../feature-docs/01-field-work.md#11-floor-plans-and-issue-pins)

### Tests

- `planPoint` round-trip through zoom / pan
- Sheet delete blocked while pins exist

## P51 · Checklist templates and results

- **Goal:** seeded built-ins; runs keep their own results; fail → prefilled issue.
- **Spec:** [13](../feature-docs/01-field-work.md#13-checklist-templates)

### Steps

1. Built-ins fork on edit; JSON import validated.

### Tests

- Fail creates one issue
- Template edit leaves completed runs unchanged

## P52 · DeviceLink and BLE mock

- **Goal:** scan → connect → read a laser or moisture meter; macOS mock for CI.
- **Spec:** [06](../feature-docs/01-field-work.md#06-devicelink-ble-measuring-tools)

| File | Holds |
|---|---|
| `DeviceLink/DeviceLinkManager.swift` | Actor around `CBCentralManager` |
| `DeviceLink/Profiles/` | One file per vendor; pure `parse` |
| `Tools/MockPeripheral/` | Scripts values, disconnects, garbage bytes |

### Steps

1. Split when you start (manager · profiles · mock).
2. Never blocks capture.

### Tests

- Vendor `parse` on real bytes
- Reconnect backoff capped
- Full flow against the mock

## P53 · Storage, cleanup, diagnostic bundle

- **Goal:** integrity checks, synced-only cleanup, redacted bundle.
- **Spec:** [09.2–09.3](../feature-docs/05-platform.md#092-integrity-checks-and-cleanup)

### Steps

1. Cleanup touches `synced` files only.
2. Redact on write.

### Tests

- Cleanup never touches pending / failed
- Redaction snapshot

## P54 · Firebase Crashlytics

- **Goal:** crash and non-fatal reporting, first at launch.
- **Spec:** [09.4](../feature-docs/05-platform.md#094-app-wide-logging)

### Steps

1. Add Firebase via `project.yml`; `GoogleService-Info.plist` written by CI, not committed.
2. First line of `didFinishLaunching`.

### Done when

- A test non-fatal shows in the Crashlytics console

## P55 · Plans UI

- **Goal:** plan list, viewer with pins and clusters, pin preview, import.
- **Spec:** Mockups (plans board)

### Steps

1. Long-press drops a pin; tap opens the issue.

### Tests

- View models
- Snapshots
- 60 fps pan / zoom with 50 pins

## P56 · Template picker, K2 checklist run

- **Goal:** one tap per item; progress “14 of 22”.
- **Spec:** Mockup K2

### Tests

- View models
- Snapshots

## P57 · Measurement overlay, device pairing

- **Goal:** reading on the camera preview, status dot, pairing in Settings.
- **Spec:** Mockup C1

### Tests

- View models
- Snapshots

## P58 · Storage screen, bundle export

- **Goal:** storage breakdown and diagnostic bundle share.

### Tests

- View model
- Snapshot

## P59 · Real logic, Instruments, TestFlight #2

- **Goal:** real plans, checklists, DeviceLink, diagnostics; first Instruments pass; TestFlight build.

| File | Holds |
|---|---|
| `SiteLog/App/AppDependencies.swift` | Swap fake registrations for the real ones |

### Steps

1. Register real implementations.
2. Run the Instruments scenarios on device (Release).
3. Push a `v*` tag.

### Done when

- Instruments scenarios 1–5 in 05 §19 within budget
- TestFlight #2 installed

## Milestone done

| Check | How |
|---|---|
| Demo | Pins on a real plan, checklist run, BLE mock reading, diagnostics |
| TestFlight #2 | Installed on a real device |
| Roadmap | P48–P59 ticked |
