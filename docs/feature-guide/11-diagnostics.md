# F11 — Diagnostics · TestFlight #2

<dl><dd>

- F11 · 17h · skeleton guide — full code is added when this feature starts.

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain + fake — Diagnostics snapshot and fake](#1-domain--fake--diagnostics-snapshot-and-fake)
4. [2. View models — Wire diagnostics and cleanup](#2-view-models--wire-diagnostics-and-cleanup)
5. [3. Real data — Storage, bundle, Crashlytics](#3-real-data--storage-bundle-crashlytics)
6. [4. Release — Instruments pass and TestFlight #2](#4-release--instruments-pass-and-testflight-2)
7. [Tests (after the feature works)](#tests-after-the-feature-works)
8. [Feature done](#feature-done)

</dd></dl>

## Overview

<dl><dd>

- **Goal:** Diagnostics end to end: Domain → fake data → view models → real data → tests.
- **Demo:** integrity check, storage cleanup, diagnostic bundle, Crashlytics; second TestFlight build.
- **Spec:** [09](../feature-docs/05-platform.md#09-diagnostics-and-observability), [19 Instruments](../feature-docs/05-platform.md#19-performance-profiling-with-instruments)
- **Starts from:** the skeleton screens (~30% of Figma) that read `App/Fakes/FakeData.swift`.
- **Fakes:** only in `Packages/DataLayer/Sources/DataLayer/Fakes/`, registered in `AppDependencies`; the dev menu seeds / clears them through `FakeDevDataActions`.
- **File tags:** <b class="tag-new">New</b> create the file · <b class="tag-edit">Edit</b> change only the part shown.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--fake--diagnostics-snapshot-and-fake) | Domain + fake | 1h | not start | Diagnostics snapshot and fake |
| [2](#2-view-models--wire-diagnostics-and-cleanup) | View models | 2h | not start | Wire diagnostics and cleanup |
| [3](#3-real-data--storage-bundle-crashlytics) | Real data | 8h | not start | Storage, bundle, Crashlytics |
| [4](#4-release--instruments-pass-and-testflight-2) | Release | 6h | not start | Instruments pass and TestFlight #2 |

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
├── DomainLayer/Sources/DomainLayer/Diagnostics/   # 1: integrity + storage snapshot
└── DataLayer/Sources/DataLayer/Fakes/   # 1: FakeDiagnosticsRepository
SiteLog/
└── Presentation/
    ├── Diagnostics/DiagnosticExport/   # 2: U3
    └── Settings/StorageCleanup/        # 2
```

</dd></dl>

## 1. Domain + fake — Diagnostics snapshot and fake

<dl><dd>

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Packages/DomainLayer/Sources/DomainLayer/Diagnostics/` | Integrity result, storage breakdown, device flags |
| <b class="tag-new">New</b> | `Packages/DataLayer/Sources/DataLayer/Fakes/FakeDiagnosticsRepository.swift` | “All 1,284 photos check out”, 4.1 / 1.6 / 12 GB |

</dd></dl>

## 2. View models — Wire diagnostics and cleanup

<dl><dd>

| Action | Skeleton folder | View model work |
|---|---|---|
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Diagnostics/DiagnosticExport/` | U3: integrity, storage, export |
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Settings/StorageCleanup/` | Synced-only cleanup |

#### Steps

<dl><dd>

1. Add `<Screen>ViewModel.swift` next to the view: `@MainActor @Observable`, use cases through `@Injected`.
2. In the view, replace `FakeData…` with view-model state; keep the layout (visual finish is F16).
3. Loading, empty (`DSEmptyState`) and error states; previews for each.
4. Delete this feature's `Fake*` types from `App/Fakes/FakeData.swift` once nothing uses them.

</dd></dl>

</dd></dl>

## 3. Real data — Storage, bundle, Crashlytics

<dl><dd>

<details open>
<summary><strong>3.1 Storage, cleanup, diagnostic bundle</strong></summary>
<dl><dd>

- **Goal:** integrity checks, synced-only cleanup, redacted bundle.
- **Spec:** [09.2–09.3](../feature-docs/05-platform.md#092-integrity-checks-and-cleanup)

#### Steps

<dl><dd>

1. Cleanup touches `synced` files only.
2. Redact on write.

</dd></dl>
</details>

<details open>
<summary><strong>3.2 Firebase Crashlytics</strong></summary>
<dl><dd>

- **Goal:** crash and non-fatal reporting, first at launch.
- **Spec:** [09.4](../feature-docs/05-platform.md#094-app-wide-logging)

</dd></dl>

#### Steps

<dl><dd>

1. Add Firebase via `project.yml`; `GoogleService-Info.plist` written by CI, not committed.
2. First line of `didFinishLaunching`.

</dd></dl>

#### Done when

<dl><dd>

- A test non-fatal shows in the Crashlytics console

</dd></dl>
</details>

</dd></dl>

</dd></dl>

## 4. Release — Instruments pass and TestFlight #2

<dl><dd>

- **Goal:** real plans, checklists, DeviceLink, diagnostics; first Instruments pass; TestFlight build.

| Action | File | Holds |
|---|---|---|
| <b class="tag-edit">Edit</b> | `SiteLog/App/AppDependencies.swift` | Swap the fake registrations for the real ones |

#### Steps

<dl><dd>

1. Register real implementations.
2. Run the Instruments scenarios on device (Release).
3. Push a `v*` tag.

</dd></dl>

#### Done when

<dl><dd>

- Instruments scenarios 1–5 in 05 §19 within budget
- TestFlight #2 installed

</dd></dl>

</dd></dl>

## Tests (after the feature works)

<dl><dd>

**3. Real data — Storage, bundle, Crashlytics**

- Cleanup never touches pending / failed
- Redaction snapshot

</dd></dl>

## Feature done

<dl><dd>

| Check | How |
|---|---|
| TestFlight #2 | Installed on a real device |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F11 steps ticked |

</dd></dl>
