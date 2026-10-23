# F06 — Markup and stamps

<dl><dd>

- Code in this guide is a teaching example. Check current source and follow [F00 localization rules](00-foundation.md#user-facing-text-and-localization) before applying it.

- F06 · 19h · skeleton guide — full code is added when this feature starts.

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain — Annotation types](#1-domain--annotation-types)
4. [2. Fake data — Annotations in memory](#2-fake-data--annotations-in-memory)
5. [3. View models — Wire markup and stamp](#3-view-models--wire-markup-and-stamp)
6. [4. Real data — Rendering and trusted time](#4-real-data--rendering-and-trusted-time)
7. [Tests (after the feature works)](#tests-after-the-feature-works)
8. [Feature done](#feature-done)

</dd></dl>

## Overview

<dl><dd>

- **Goal:** Markup and stamps end to end: Domain → fake data → view models → real data → tests.
- **Demo:** markup saved as a layer over the original; stamped copy shared with trusted time.
- **Spec:** [12](../feature-docs/01-field-work.md#12-annotation-and-verifiable-stamps)
- **Starts from:** the skeleton screens (~30% of Figma) that read `App/Fakes/FakeData.swift`.
- **No fake repository:** the fake-data step writes the real implementation on in-memory values, registered once in `App/DI/RepositoriesDI.swift`; the real-data step swaps its insides, never the type. The dev menu seeds / clears it through Debug-only `UseCases/DevData/` use cases; test doubles live only in test targets.
- **File tags:** <b class="tag-new">New</b> create the file · <b class="tag-edit">Edit</b> change only the part shown.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--annotation-types) | Domain | 1h | not start | Annotation types |
| [2](#2-fake-data--annotations-in-memory) | Fake data | 1h | not start | `AnnotationRepositoryImpl` in memory |
| [3](#3-view-models--wire-markup-and-stamp) | View models | 4h | not start | Wire markup and stamp |
| [4](#4-real-data--rendering-and-trusted-time) | Real data | 13h | not start | Rendering and trusted time |

<details open>
<summary><strong>Order</strong></summary>
<dl><dd>

- Steps run top to bottom; the app runs after every step.
- Real data changes only registrations in `App/DI/`, never views or view models.
- Tests come last, once the feature works end to end.

</dd></dl>
</details>

</dd></dl>

## Target structure

<dl><dd>

```text
Packages/
├── DomainLayer/Sources/DomainLayer/Entities/Annotation/                     # 1: AnnotationShape, NormalizedPoint
├── DataLayer/Sources/DataLayer/Repositories/                                # 2: AnnotationRepositoryImpl in memory, fixed trusted time
└── PlatformKit/Sources/PlatformKit/Rendering/Annotation/, Device/TrustedTime/  # 4
SiteLog/
└── Presentation/Annotation/                                                 # 3: MarkupEditor, StampPreview
```

</dd></dl>

## 1. Domain — Annotation types

<dl><dd>

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Packages/DomainLayer/Sources/DomainLayer/Entities/Annotation/` | `AnnotationShape`, `NormalizedPoint` (0…1), `TrustedTimestamp` |

</dd></dl>

## 2. Fake data — Annotations in memory

<dl><dd>

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Packages/DataLayer/Sources/DataLayer/Repositories/AnnotationRepositoryImpl.swift` | Annotation layers per capture; a fixed trusted time until the real-data step |
| <b class="tag-edit">Edit</b> | `SiteLog/App/DI/RepositoriesDI.swift`, `UseCasesDI.swift` | Registers it and its DevData use cases once; the real-data step keeps these registrations |

#### Steps

<dl><dd>

1. Implement the Domain protocol under its real name as an `actor` that keeps everything in memory for now.
2. Seed it with one markup on the crack photo — move the values out of `App/Fakes/FakeData.swift`.
3. Debug only: add `resetAllData()` / `seedSampleData()` to the repository protocol and `Impl`, add `ResetAll<Feature>DataUseCase` / `Seed<Feature>DataUseCase` in `UseCases/DevData/`, call them from `DevMenuViewModel`.
4. Register it in `App/DI/RepositoriesDI.swift`, its DevData use cases in `App/DI/UseCasesDI.swift` (`#if DEBUG`).

</dd></dl>

</dd></dl>

## 3. View models — Wire markup and stamp

<dl><dd>

| Action | Skeleton folder | View model work |
|---|---|---|
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Annotation/MarkupEditor/` | M1: tools, colours, undo capped at `maxUndoSteps`, commit on exit |
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Annotation/StampPreview/` | M2: stamp toggles, share |

#### Steps

<dl><dd>

1. Add `<Screen>ViewModel.swift` next to the view: `@MainActor @Observable`, use cases through `init`; the view builds it with `Container.shared.<useCase>()`.
   Pushes go through `coordinator.push(<Feature>Route…)`; add the case and its screen in `<Feature>Route.swift` ([D19](../feature-docs/00-overview.md#d19--feature-routes-and-a-coordinator-per-stack)).
2. In the view, replace `FakeData…` with view-model state; keep the layout (visual finish is F16).
3. Loading, empty (`DSEmptyState`) and error states; previews for each.
4. Delete this feature's `Fake*` types from `App/Fakes/FakeData.swift` once nothing uses them.

</dd></dl>

</dd></dl>

## 4. Real data — Rendering and trusted time

<dl><dd>

<details open>
<summary><strong>4.1 Annotation model and rendering</strong></summary>
<dl><dd>

- **Goal:** vector markup layer that never touches the original.
- **Spec:** [12.1](../feature-docs/01-field-work.md#121-annotation-layer)

#### Steps

<dl><dd>

1. Normalized coordinates (0…1).
2. Stroke scales with image width.

</dd></dl>
</details>

<details open>
<summary><strong>4.2 Trusted time and stamped derivative</strong></summary>
<dl><dd>

- **Goal:** `TrustedTimestamp` with confidence; stamped JPEG copies on demand.
- **Spec:** [12.2, 12.4](../feature-docs/01-field-work.md#124-trusted-time)

</dd></dl>

#### Steps

<dl><dd>

1. Offset from the backend `Date` header.
2. Derived images never hashed, never evidence.

</dd></dl>
</details>

</dd></dl>

</dd></dl>

## Tests (after the feature works)

<dl><dd>

**1. Domain — Annotation types**

- `AnnotationShape` Codable round-trip

**3. View models — Wire markup and stamp**

- Undo bounds

**4. Real data — Rendering and trusted time**

- Same render at two sizes
- Original never mutated
- Confidence for fresh / stale offset, clock jump, relaunch
- Stamp position correct in three orientations

</dd></dl>

## Feature done

<dl><dd>

| Check | How |
|---|---|
| Demo | Markup on a photo; original hash unchanged; stamped copy shared |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F06 steps ticked |

</dd></dl>
