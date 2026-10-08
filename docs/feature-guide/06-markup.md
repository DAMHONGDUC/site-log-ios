# F06 — Markup and stamps

<dl><dd>

- F06 · 19h · skeleton guide — full code is added when this feature starts.

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain — Annotation types](#1-domain--annotation-types)
4. [2. Fake data — In-memory annotations](#2-fake-data--in-memory-annotations)
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
- **Starts from:** the skeleton screens (~30% of Figma) that read `Core/Fakes/FakeData.swift`.
- **Fakes:** only in `SiteLog/Data/Fakes/`, registered in `AppDependencies`; the dev menu seeds / clears them through `FakeDevDataActions`.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--annotation-types) | Domain | 1h | not start | Annotation types |
| [2](#2-fake-data--in-memory-annotations) | Fake data | 1h | not start | In-memory annotations |
| [3](#3-view-models--wire-markup-and-stamp) | View models | 4h | not start | Wire markup and stamp |
| [4](#4-real-data--rendering-and-trusted-time) | Real data | 13h | not start | Rendering and trusted time |

<details open>
<summary><b>Order</b></summary>
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
├── Domain/Annotation/                    # 1: AnnotationShape, NormalizedPoint
├── Data/Fakes/                           # 2: InMemoryAnnotationRepository, FixedTrustedClock
├── DataSources/Capture/Annotation/, TrustedTime/   # 4
└── Presentation/Annotation/              # 3: MarkupEditor, StampPreview
```

</dd></dl>

## 1. Domain — Annotation types

<dl><dd>

| File | Holds |
|---|---|
| `Domain/Annotation/` | `AnnotationShape`, `NormalizedPoint` (0…1), `TrustedTimestamp` |

</dd></dl>

## 2. Fake data — In-memory annotations

<dl><dd>

| File | Holds |
|---|---|
| `SiteLog/Data/Fakes/InMemoryAnnotationRepository.swift` | Annotation layers per capture; a fixed trusted time |
| `SiteLog/App/AppDependencies.swift` | Registers the fake; the real step only changes this line |

#### Steps

<dl><dd>

1. Implement the Domain protocol as an `actor` that keeps everything in memory.
2. Seed it with one markup on the crack photo — move the values out of `Core/Fakes/FakeData.swift`.
3. Add `reset()` (empty) and `seed()`; `FakeDevDataActions` calls them from the dev menu.
4. Register it in `AppDependencies`.

</dd></dl>

</dd></dl>

## 3. View models — Wire markup and stamp

<dl><dd>

| Skeleton folder | View model work |
|---|---|
| `Presentation/Annotation/MarkupEditor/` | M1: tools, colours, undo capped at `maxUndoSteps`, commit on exit |
| `Presentation/Annotation/StampPreview/` | M2: stamp toggles, share |

#### Steps

<dl><dd>

1. Add `<Screen>ViewModel.swift` next to the view: `@MainActor @Observable`, use cases through `@Injected`.
2. In the view, replace `FakeData…` with view-model state; keep the layout (visual finish is F16).
3. Loading, empty (`DSEmptyState`) and error states; previews for each.
4. Delete this feature's `Fake*` types from `Core/Fakes/FakeData.swift` once nothing uses them.

</dd></dl>

</dd></dl>

## 4. Real data — Rendering and trusted time

<dl><dd>

<details open>
<summary><b>4.1 Annotation model and rendering</b></summary>
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
<summary><b>4.2 Trusted time and stamped derivative</b></summary>
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
- Stamp snapshot in three orientations

</dd></dl>

## Feature done

<dl><dd>

| Check | How |
|---|---|
| Demo | Markup on a photo; original hash unchanged; stamped copy shared |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F06 steps ticked |

</dd></dl>
