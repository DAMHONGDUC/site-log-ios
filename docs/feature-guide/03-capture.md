# F03 — Capture

<dl><dd>

- F03 · 20h · skeleton guide — full code is added when this feature starts.

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain — Record a capture](#1-domain--record-a-capture)
4. [2. Fake data — Fake capture source](#2-fake-data--fake-capture-source)
5. [3. View models — Wire the camera](#3-view-models--wire-the-camera)
6. [4. Real data — Camera, disk, SHA-256](#4-real-data--camera-disk-sha-256)
7. [Tests (after the feature works)](#tests-after-the-feature-works)
8. [Feature done](#feature-done)

</dd></dl>

## Overview

<dl><dd>

- **Goal:** Capture end to end: Domain → fake data → view models → real data → tests.
- **Demo:** photo captured and hashed in airplane mode, linked to a location, kept after relaunch.
- **Spec:** [02](../feature-docs/01-field-work.md#02-capture-pipeline)
- **Starts from:** the skeleton screens (~30% of Figma) that read `Core/Fakes/FakeData.swift`.
- **Fakes:** only in `SiteLog/Data/Fakes/`, registered in `AppDependencies`; the dev menu seeds / clears them through `FakeDevDataActions`.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--record-a-capture) | Domain | 1h | not start | Record a capture |
| [2](#2-fake-data--fake-capture-source) | Fake data | 2h | not start | Fake capture source |
| [3](#3-view-models--wire-the-camera) | View models | 3h | not start | Wire the camera |
| [4](#4-real-data--camera-disk-sha-256) | Real data | 14h | not start | Camera, disk, SHA-256 |

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
SiteLog/
├── Domain/Capture/              # 1: RecordCaptureUseCase, CaptureSource protocol
├── Data/Fakes/FakeCaptureSource.swift   # 2: returns a bundled image
├── DataSources/Capture/         # 4: CaptureSessionControlling, AVCaptureSessionController, FileHasher, MediaStore
└── Presentation/Capture/        # 3: Camera, CaptureReview
```

</dd></dl>

## 1. Domain — Record a capture

<dl><dd>

| File | Holds |
|---|---|
| `Domain/Capture/CaptureSource.swift` | Protocol: start, stop, takePhoto → file URL + metadata |
| `Domain/Capture/RecordCaptureUseCase.swift` | Write → hash → save `Capture` (entity from F02) |

</dd></dl>

## 2. Fake data — Fake capture source

<dl><dd>

| File | Holds |
|---|---|
| `SiteLog/Data/Fakes/FakeCaptureSource.swift` | Returns a bundled JPEG; works in the Simulator |
| `SiteLog/App/AppDependencies.swift` | Registers the fake |

</dd></dl>

## 3. View models — Wire the camera

<dl><dd>

| Skeleton folder | View model work |
|---|---|
| `Presentation/Capture/Camera/` | C1: shutter, mode, room pill, thumbnail count |
| `Presentation/Capture/CaptureReview/` | Hash + time, retake / use photo |

#### Steps

<dl><dd>

1. Add `<Screen>ViewModel.swift` next to the view: `@MainActor @Observable`, use cases through `@Injected`.
2. In the view, replace `FakeData…` with view-model state; keep the layout (visual finish is F16).
3. Loading, empty (`DSEmptyState`) and error states; previews for each.
4. Delete this feature's `Fake*` types from `Core/Fakes/FakeData.swift` once nothing uses them.
5. Hi-vis yellow only on the shutter; never blocks on upload state.

</dd></dl>

</dd></dl>

## 4. Real data — Camera, disk, SHA-256

<dl><dd>

<details open>
<summary><strong>4.1 Camera session and permissions</strong></summary>
<dl><dd>

- **Goal:** one `AVCaptureSession` behind `CaptureSessionControlling`, testable without a camera.
- **Spec:** [02.1](../feature-docs/01-field-work.md#021-session-and-state)

| File | Holds |
|---|---|
| `SiteLog/DataSources/Capture/CaptureSessionControlling.swift` | Protocol: configure, start, stop, capturePhoto |
| `Capture/AVCaptureSessionController.swift` | Real implementation on `sessionQueue` |
| `Capture/CaptureState.swift` | `idle → configuring → ready → capturingPhoto` |

#### Steps

<dl><dd>

1. Never `startRunning()` on main.
2. Camera, mic, location permissions asked separately.
3. Add `NSCameraUsageDescription` etc. via `project.yml` `INFOPLIST_KEY_*`.

</dd></dl>
</details>

<details open>
<summary><strong>4.2 Write to disk and SHA-256</strong></summary>
<dl><dd>

- **Goal:** each photo written to `media/…` and hashed before the DB row exists.
- **Spec:** [02.2](../feature-docs/01-field-work.md#022-metadata-and-hashing)

| File | Holds |
|---|---|
| `Capture/FileHasher.swift` | Streams SHA-256 in 1 MB chunks |
| `Capture/MediaStore.swift` | Path `media/<project>/<session>/<capture>.<ext>`, `.completeUnlessOpen`, excluded from backup |

</dd></dl>

#### Steps

<dl><dd>

1. Write → close → hash → insert row (no row without a hash).
2. GPS older than `locationStaleAfter` is `nil`.

</dd></dl>
</details>

<details open>
<summary><strong>4.3 Real logic behind the screens</strong></summary>
<dl><dd>

- **Goal:** swap fakes for SwiftData repositories and the real camera; run the airplane-mode demo.

| File | Holds |
|---|---|
| `SiteLog/App/AppDependencies.swift` | Register `SwiftData*Repository`, `AVCaptureSessionController` |

</dd></dl>

#### Steps

<dl><dd>

1. Change registrations only; no view code changes.
2. Airplane mode on a real device: project → 80 locations → capture.
3. Tick the feature steps in ROADMAP.

</dd></dl>

#### Done when

<dl><dd>

- 50 photos with flat memory
- Relaunch shows every capture with its hash

</dd></dl>
</details>

</dd></dl>

</dd></dl>

## Tests (after the feature works)

<dl><dd>

**3. View models — Wire the camera**

- Camera view model state transitions

**4. Real data — Camera, disk, SHA-256**

- State machine rejects recording during photo
- Interruption finalizes once
- Hash against known vectors and `shasum` on 200 MB
- Stale GPS → `nil`

</dd></dl>

## Feature done

<dl><dd>

| Check | How |
|---|---|
| Demo | Airplane mode on device: project → location → hashed photo, 50 photos with flat memory |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F03 steps ticked |

</dd></dl>
