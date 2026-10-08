# Roadmap

- Milestones run in order; a milestone is done when its demo runs on a real device.
- Inside a milestone, UI and Logic run in parallel on two tracks.
- Specs: [docs/feature-docs](docs/feature-docs/); step-by-step guides: [docs/milestone-guide](docs/milestone-guide/).

## Contents

1. [How work is split](#how-work-is-split)
2. [Summary](#summary)
3. [M0 — Scaffold](#m0--scaffold--30h)
4. [M1 — Record offline](#m1--record-offline--51h)
5. [M2 — Bytes land](#m2--bytes-land--testflight-1--89h)
6. [M3 — Deliverable](#m3--deliverable--82h)
7. [M4 — Field-ready](#m4--field-ready--testflight-2--61h)
8. [M5 — Multi-device](#m5--multi-device--60h)
9. [M6 — Polish](#m6--polish--45h)
10. [M7 — UI finish](#m7--ui-finish--48h)
11. [Tracks](#tracks)
12. [Rules](#rules)

## How work is split

```mermaid
flowchart LR
    C["Contract<br/>Domain types, protocols, fakes"] --> U["UI track<br/>views + view models on fakes"]
    C --> L["Logic track<br/>repositories, engines, backend"]
    U --> J["Join<br/>swap fakes for real, demo"]
    L --> J
```

- Format: `PXX - [docs-number] - [track] - [context] - [est hours] - description`.
- `[docs-number]` is the spec in `docs/feature-docs/` (`-` if none).
- `[track]` is `Contract`, `UI`, `Logic` or `Join`.
- `[Backend]` parts are Node.js work in `Backend/`; every other context is the iOS app.

- UI is built in two passes:
  - **Skeleton (~30% of Figma) — done:** every screen, navigation and `FakeData`; no view models.
  - **Finish (the other ~70%) — `M7`, last:** spacing, imagery, custom controls, states, dark mode to Figma.
  - So a UI part in `M0`–`M6` adds the view model, states and previews to a screen that already exists.

- Estimates: dev-hours for one developer new to Swift and SwiftUI, learning included; time the first
  parts, then scale the rest.

## Summary

```mermaid
flowchart TD
    M0["M0 Scaffold<br/>P01 – P07"]
    M0 --> M1["M1 Record offline<br/>P08 – P18"]
    M1 --> M2["M2 Bytes land<br/>P19 – P32<br/>TestFlight #1"]
    M2 --> M3["M3 Deliverable<br/>P33 – P47"]
    M3 --> M4["M4 Field-ready<br/>P48 – P59<br/>TestFlight #2"]
    M4 --> M5["M5 Multi-device<br/>P60 – P70"]
    M5 --> M6["M6 Polish<br/>P71 – P79"]
    M6 --> M7["M7 UI finish<br/>P80 – P88<br/>App Store"]

    classDef ship fill:#EEEDFE,stroke:#534AB7,color:#3C3489
    class M2,M4,M7 ship
```

| | |
|---|---|
| Total | 87 open parts ≈ 458 hours (`P01` done) — UI 120h, Logic 279h |
| Key milestone | `M2`: everything before it is setup, everything after it is addition |
| Goal | App Store release with the full scope in `M0`–`M7`; no milestone is dropped |
| UI skeleton | Done 2026-10-08: every screen of `M0`–`M6` at ~30% of Figma on `FakeData`, debug dev menu in Settings |

## M0 — Scaffold · 30h

- Demo: the app builds with zero warnings, CI is green; DesignSystem and the access flow run on fakes.
- Guide: [docs/milestone-guide/m0-scaffold.md](docs/milestone-guide/m0-scaffold.md)

**Logic**

- [x] **P01** - [-] - [Logic] - [Tooling] - [8h] - Xcode project, XcodeGen, SwiftLint, hot reload, tooling
- [ ] **P02** - [00] - [Logic] - [Domain] - [6h] - Clean Architecture skeleton: `Domain/`, `Data/` folders + `DesignSystem` package (`DataSources/Networking/` is created in M2); Factory DI in `AppDependencies`; injected `AppClock`; test libraries (swift-snapshot-testing, `FactoryTesting`)
- [ ] **P03** - [17] - [Logic] - [CI] - [5h] - Fastlane `test` lane and GitHub Actions PR checks
- [ ] **P04** - [17] - [Logic] - [CI] - [4h] - CI guards: layer rules, app builds with zero warnings, no `print(`, secret scan

**UI**

- [ ] **P05** - [-] - [UI] - [DesignSystem] - [1h] - Tokens from the Foundations board: colours (light + dark), type scale, spacing, radius — built with the skeleton; remaining: hex-decoding test
- [ ] **P06** - [-] - [UI] - [DesignSystem] - [2h] - Components: buttons, list rows, chips, badges, empty state — built with the skeleton; remaining: `DSGallery` + snapshot test
- [ ] **P07** - [07,08] - [UI] - [Access] - [4h] - Access flow on fakes: `InMemoryAccessRepository`, `RootViewModel` and passcode view model behind the A1–A3 skeleton screens; privacy overlay and re-lock

## M1 — Record offline · 51h

- Demo: project → 80 locations → photo captured and hashed, **in airplane mode**.
- Guide: [docs/milestone-guide/m1-record-offline.md](docs/milestone-guide/m1-record-offline.md)

**Contract**

- [ ] **P08** - [00,01,02] - [Contract] - [Domain] - [5h] - Entities (`Project`, `Session`, `Location`, `Capture`), repository protocols, use cases, in-memory fakes and preview data

**Logic**

- [ ] **P09** - [00] - [Logic] - [Persistence] - [7h] - SwiftData schema and repository implementations
- [ ] **P10** - [00] - [Logic] - [Persistence] - [8h] - Schema versioning, migrations, store tests
- [ ] **P11** - [01] - [Logic] - [Locations] - [3h] - Bulk-generate and import 80 locations offline (use cases + tests)
- [ ] **P12** - [02] - [Logic] - [Capture] - [6h] - Camera session and permissions behind `CaptureSessionControlling`
- [ ] **P13** - [02] - [Logic] - [Capture] - [5h] - Write to disk and SHA-256 hash

**UI**

- [ ] **P14** - [01] - [UI] - [Projects] - [3h] - P1 project list, P2 new project sheet — view model, states and previews on the skeleton screen
- [ ] **P15** - [01] - [UI] - [Projects] - [3h] - P3 project overview, P4 start session — view model, states and previews on the skeleton screen
- [ ] **P16** - [01] - [UI] - [Sessions] - [4h] - P5 walkthrough rooms, P6 generate locations, P7 room — view model, states and previews on the skeleton screen
- [ ] **P17** - [02] - [UI] - [Capture] - [3h] - C1 camera screen on a fake capture session — view model, states and previews on the skeleton screen

**Join**

- [ ] **P18** - [02] - [Join] - [Capture] - [4h] - Real repositories and capture behind the screens; metadata linked to a location; airplane-mode demo

## M2 — Bytes land · TestFlight #1 · 89h

- Demo: 200 files reach storage and survive app kill and airplane mode.
- Guide: [docs/milestone-guide/m2-bytes-land.md](docs/milestone-guide/m2-bytes-land.md)

**Contract**

- [ ] **P19** - [04] - [Contract] - [UploadKit] - [3h] - `UploadKit` public API: job, states, `UploadStore` protocol, fake store

**Logic**

- [ ] **P20** - [14] - [Logic] - [Backend] - [6h] - Backend skeleton and first migrations
- [ ] **P21** - [14] - [Logic] - [Backend] - [5h] - Presigned upload endpoint and object storage
- [ ] **P22** - [14] - [Logic] - [Backend] - [4h] - Refresh, complete and abort endpoints
- [ ] **P23** - [04] - [Logic] - [UploadKit] - [6h] - `UploadKit`: job model and local store
- [ ] **P24** - [04] - [Logic] - [UploadKit] - [10h] - `UploadKit`: single PUT through a background `URLSession`
- [ ] **P25** - [04] - [Logic] - [UploadKit] - [6h] - `UploadKit`: state machine, retry, backoff
- [ ] **P26** - [04] - [Logic] - [UploadKit] - [14h] - `UploadKit`: multipart and resume
- [ ] **P27** - [04] - [Logic] - [UploadKit] - [10h] - `UploadKit`: kill and relaunch reconciliation
- [ ] **P28** - [04] - [Logic] - [UploadKit] - [6h] - Network policy (Wi-Fi only) and upload-URL refresh

**UI**

- [ ] **P29** - [09] - [UI] - [Diagnostics] - [3h] - S10 upload status screen on the fake store — view model, states and previews on the skeleton screen
- [ ] **P30** - [04] - [UI] - [Uploads] - [3h] - Sync tab: queue summary, per-capture upload badge, Wi-Fi only setting — view model, states and previews on the skeleton screen

**Join**

- [ ] **P31** - [04] - [Join] - [UploadKit] - [3h] - `UploadKit` behind the screens; 200-file demo
- [ ] **P32** - [17] - [Join] - [Release] - [10h] - Signing, App Store Connect API key, first TestFlight build

## M3 — Deliverable · 82h

- Demo: an issue logged and re-checked as a before/after pair; a signed, branded PDF and a CSV from a real session; app lock live.
- Guide: [docs/milestone-guide/m3-deliverable.md](docs/milestone-guide/m3-deliverable.md)

**Contract**

- [ ] **P33** - [03,05,07,12] - [Contract] - [Domain] - [4h] - `Issue`, `Annotation`, `Report`, `AuditEntry`, app-lock settings; protocols and fakes

**Logic**

- [ ] **P34** - [03] - [Logic] - [Issues] - [6h] - Issue CRUD, carry-over of open issues, pairing and closure by verification photo
- [ ] **P35** - [03] - [Logic] - [Issues] - [6h] - Phrase library, on-device dictation, voice notes
- [ ] **P36** - [07] - [Logic] - [Security] - [8h] - App lock: Face ID (`LAContext`), PBKDF2 passcode in Keychain, lockout, Lock after; replaces the M0 fake
- [ ] **P37** - [07] - [Logic] - [Security] - [5h] - Audit chain
- [ ] **P38** - [12] - [Logic] - [Annotation] - [6h] - Annotation model and rendering
- [ ] **P39** - [12] - [Logic] - [Annotation] - [8h] - Trusted time and the stamped derivative
- [ ] **P40** - [05] - [Logic] - [Reporting] - [5h] - Report data model and CSV export
- [ ] **P41** - [05] - [Logic] - [Reporting] - [12h] - PDF renderer

**UI**

- [ ] **P42** - [03] - [UI] - [Issues] - [4h] - C2 log issue sheet, C5 issue list, open-issues banner — view model, states and previews on the skeleton screen
- [ ] **P43** - [03] - [UI] - [Issues] - [3h] - C3 re-check ghost overlay, C4 outcome picker — view model, states and previews on the skeleton screen
- [ ] **P44** - [07] - [UI] - [Settings] - [3h] - S4 app lock settings, S5 set passcode, forgot-passcode flow — view model, states and previews on the skeleton screen
- [ ] **P45** - [12] - [UI] - [Annotation] - [4h] - Markup editor (arrow, box, circle, text), stamped image preview — view model, states and previews on the skeleton screen
- [ ] **P46** - [05] - [UI] - [Reporting] - [4h] - Report builder, branding settings, signature pad, PDF preview and share sheet — view model, states and previews on the skeleton screen

**Join**

- [ ] **P47** - [03,05,07] - [Join] - [Reporting] - [4h] - Real logic behind issues, lock and reports; PDF and CSV exported from a real session

## M4 — Field-ready · TestFlight #2 · 61h

- Demo: pins on a real floor plan, checklists, BLE mock, diagnostics.
- Guide: [docs/milestone-guide/m4-field-ready.md](docs/milestone-guide/m4-field-ready.md)

**Contract**

- [ ] **P48** - [06,09,11,13] - [Contract] - [Domain] - [3h] - `PlanSheet`, `Pin`, checklist template and run, `DeviceLink` protocol, diagnostics snapshot; fakes

**Logic**

- [ ] **P49** - [11] - [Logic] - [Plans] - [6h] - Floor plan import and storage
- [ ] **P50** - [11] - [Logic] - [Plans] - [4h] - Pin coordinates and persistence
- [ ] **P51** - [13] - [Logic] - [Checklists] - [5h] - Seeded checklist templates, run results
- [ ] **P52** - [06] - [Logic] - [DeviceLink] - [14h] - DeviceLink protocol and BLE mock
- [ ] **P53** - [09] - [Logic] - [Diagnostics] - [6h] - Storage breakdown, cleanup, diagnostic bundle
- [ ] **P54** - [09] - [Logic] - [Diagnostics] - [3h] - Firebase Crashlytics

**UI**

- [ ] **P55** - [11] - [UI] - [Plans] - [5h] - Plan list, plan viewer with pins and clusters, pin preview, plan import — view model, states and previews on the skeleton screen
- [ ] **P56** - [13] - [UI] - [Checklists] - [4h] - Template picker, K2 checklist run — view model, states and previews on the skeleton screen
- [ ] **P57** - [06] - [UI] - [DeviceLink] - [3h] - Measurement overlay and device status dot on C1; device pairing in Settings — view model, states and previews on the skeleton screen
- [ ] **P58** - [09] - [UI] - [Diagnostics] - [2h] - Storage screen and diagnostic bundle export — view model, states and previews on the skeleton screen

**Join**

- [ ] **P59** - [09,19] - [Join] - [Release] - [6h] - Real logic behind the screens, first Instruments pass, TestFlight build

## M5 — Multi-device · 60h

- Demo: a second device sees the same data and deletes propagate.
- Guide: [docs/milestone-guide/m5-multi-device.md](docs/milestone-guide/m5-multi-device.md)

**Contract**

- [ ] **P60** - [08] - [Contract] - [Domain] - [2h] - Auth and sync protocols, fakes

**Logic**

- [ ] **P61** - [08] - [Logic] - [Auth] - [7h] - Firebase Auth (Apple, email) and ID-token handling (server-side check is in the backend skeleton)
- [ ] **P62** - [14] - [Logic] - [Backend] - [6h] - Backend pull and push endpoints
- [ ] **P63** - [08] - [Logic] - [Sync] - [8h] - Sync engine: pull
- [ ] **P64** - [08] - [Logic] - [Sync] - [12h] - Sync engine: push and conflict rules
- [ ] **P65** - [08] - [Logic] - [Sync] - [6h] - Deletes propagate (tombstones)
- [ ] **P66** - [08] - [Logic] - [Sync] - [8h] - Two-device convergence test

**UI**

- [ ] **P67** - [08] - [UI] - [Auth] - [3h] - A2 real buttons: Sign in with Apple, email sign-in screens — view model, states and previews on the skeleton screen
- [ ] **P68** - [08] - [UI] - [Settings] - [3h] - Account: profile, sign out, delete account — view model, states and previews on the skeleton screen
- [ ] **P69** - [08] - [UI] - [Sync] - [2h] - Sync status in the Sync tab: last synced, errors — view model, states and previews on the skeleton screen

**Join**

- [ ] **P70** - [08] - [Join] - [Sync] - [3h] - Real auth and sync behind the screens; two-device demo

## M6 — Polish · 45h

- Demo: realtime state, push, deep links, accessibility; feature-complete, ready for the UI finish in `M7`.
- Guide: [docs/milestone-guide/m6-polish.md](docs/milestone-guide/m6-polish.md)

**Logic**

- [ ] **P71** - [10] - [Logic] - [Realtime] - [6h] - Realtime client: connect, auth, ping, reconnect
- [ ] **P72** - [10] - [Logic] - [Realtime] - [6h] - Realtime events reconciled into the upload store
- [ ] **P73** - [14] - [Logic] - [Backend] - [6h] - Verification worker
- [ ] **P74** - [18] - [Logic] - [Push] - [6h] - Push notifications
- [ ] **P75** - [18] - [Logic] - [DeepLinks] - [3h] - Deep links

**UI**

- [ ] **P76** - [10] - [UI] - [Realtime] - [2h] - Live server state on the upload screen — view model, states and previews on the skeleton screen
- [ ] **P77** - [18] - [UI] - [Push] - [2h] - Notification permission prompt and settings
- [ ] **P78** - [-] - [UI] - [Accessibility] - [8h] - Accessibility pass (Dynamic Type, VoiceOver, contrast)

**Join**

- [ ] **P79** - [19,17] - [Join] - [Release] - [6h] - Instruments budgets, TestFlight feedback closed (submission moves to `P88`)

## M7 — UI finish · 48h

- Demo: every screen matches Figma side by side in light and dark mode; the build is submitted to the App Store.
- Guide: [docs/milestone-guide/m7-ui-finish.md](docs/milestone-guide/m7-ui-finish.md)
- Starts from the ~30% skeleton; this milestone does the remaining ~70% of the visual work, on real logic.

**UI**

- [ ] **P80** - [-] - [UI] - [DesignSystem] - [6h] - Components to Figma: buttons, rows, chips, severity segmented control, fields, toggles, radio; snapshot references re-recorded
- [ ] **P81** - [07,08] - [UI] - [Access] - [3h] - S1 to Figma: app mark from the icon asset, sign in, Face ID lock, passcode pad, privacy overlay
- [ ] **P82** - [01] - [UI] - [Projects] - [6h] - S2–S3 to Figma: P1–P7, bulk locations, clone tree, end session
- [ ] **P83** - [02,03,06] - [UI] - [Capture] - [6h] - S4–S5 to Figma: camera chrome, capture review, measurement overlay, C2–C6
- [ ] **P84** - [11,12] - [UI] - [Plans] - [5h] - S6–S7 to Figma: markup editor, stamp preview, plan list, plan viewer with real pins and clusters
- [ ] **P85** - [05,13] - [UI] - [Reports] - [6h] - S8–S9 to Figma: K1–K4 (Pass/Fail/N/A answer row), R1–R5
- [ ] **P86** - [04,06,07,08,09] - [UI] - [Settings] - [5h] - S10–S11 to Figma: U1–U3, S1–S5, storage cleanup, account
- [ ] **P87** - [-] - [UI] - [Polish] - [5h] - Dark mode pass; empty, error and offline states on every screen; real imagery instead of placeholders

**Join**

- [ ] **P88** - [17] - [Join] - [Release] - [6h] - Accessibility re-check after the finish, App Store screenshots and listing, submission

## Tracks

| Track | Builds | Never |
|---|---|---|
| Contract | `Domain` entities, repository and use-case protocols, in-memory fakes, preview data | UI, persistence, network |
| UI | Views and view models against the fakes; previews for every state; snapshot tests | Real persistence, network, Keychain, camera |
| Logic | Repositories, data sources, engines, backend; unit tests | SwiftUI |
| Join | Swaps the fake registrations in `AppDependencies` for the real ones; runs the demo | New features |

## Rules

1. A part ends with something runnable or a passing test, never "half a screen".
2. Each milestone opens with its `Contract` part. UI and Logic both build against it only, so they
   never wait on each other. A contract change updates the protocol and the fake in the same commit.
3. The UI track may run up to one milestone ahead on fakes; the Logic track never waits for UI.
4. A milestone ends with its `Join` part; its demo runs on real logic, never on fakes.
5. A part estimated above 8h (`P24`, `P26`, `P27`, `P32`, `P41`, `P52`, `P64`) is split when you start it. If any
   part runs long, split it and renumber; do not let it swallow the next one.
6. Tick the box in the same commit that finishes the part.
7. Order is by dependency: `P32` needs `P20`–`P31`, `P41` needs `P39`, `P71` needs `P61`–`P70`.
8. Visual work to Figma waits for `M7`; until then a UI part changes layout only when a view model needs it.
