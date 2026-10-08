# F08 — Floor plans and pins

- F08 · 16h · skeleton guide — full code is added when this feature starts.

## Contents

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain — Plan types](#1-domain--plan-types)
4. [2. Fake data — In-memory plans](#2-fake-data--in-memory-plans)
5. [3. View models — Wire the Plans screens](#3-view-models--wire-the-plans-screens)
6. [4. Real data — Import and pins](#4-real-data--import-and-pins)
7. [Tests (after the feature works)](#tests-after-the-feature-works)
8. [Feature done](#feature-done)

## Overview

- **Goal:** Floor plans and pins end to end: Domain → fake data → view models → real data → tests.
- **Demo:** real PDF plan imported, issues pinned, pins survive relaunch.
- **Spec:** [11](../feature-docs/01-field-work.md#11-floor-plans-and-issue-pins)
- **Starts from:** the skeleton screens (~30% of Figma) that read `Core/Fakes/FakeData.swift`.
- **Fakes:** only in `SiteLog/Data/Fakes/`, registered in `AppDependencies`; the dev menu seeds / clears them through `FakeDevDataActions`.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--plan-types) | Domain | 1h | not start | Plan types |
| [2](#2-fake-data--in-memory-plans) | Fake data | 1h | not start | In-memory plans |
| [3](#3-view-models--wire-the-plans-screens) | View models | 5h | not start | Wire the Plans screens |
| [4](#4-real-data--import-and-pins) | Real data | 9h | not start | Import and pins |

<details open>
<summary><b>Order</b></summary>

- Steps run top to bottom; the app runs after every step.
- Real data changes only registrations in `AppDependencies`, never views or view models.
- Tests come last, once the feature works end to end.

</details>

## Target structure

```text
SiteLog/
├── Domain/Plans/          # 1: PlanSheet, pin as NormalizedPoint
├── Data/Fakes/            # 2: InMemoryPlanRepository
├── DataSources/Plans/     # 4: PDFKit + CATiledLayer, tile cache
└── Presentation/Plans/    # 3: PlanList, PlanViewer, PinPreview, PlanImport
```

## 1. Domain — Plan types

| File | Holds |
|---|---|
| `Domain/Plans/` | `PlanSheet`, `Pin` (`NormalizedPoint`), import / pin / move use cases |

## 2. Fake data — In-memory plans

| File | Holds |
|---|---|
| `SiteLog/Data/Fakes/InMemoryPlanRepository.swift` | Plan sheets and pins |
| `SiteLog/App/AppDependencies.swift` | Registers the fake; the real step only changes this line |

#### Steps

1. Implement the Domain protocol as an `actor` that keeps everything in memory.
2. Seed it with 4 sheets, 6 pins — move the values out of `Core/Fakes/FakeData.swift`.
3. Add `reset()` (empty) and `seed()`; `FakeDevDataActions` calls them from the dev menu.
4. Register it in `AppDependencies`.

## 3. View models — Wire the Plans screens

| Skeleton folder | View model work |
|---|---|
| `Presentation/Plans/PlanList/` | M3: sheets of a project |
| `Presentation/Plans/PlanViewer/` | M4: pins and clusters; long-press drops a pin |
| `Presentation/Plans/PinPreview/` | M5: issue summary, move, open |
| `Presentation/Plans/PlanImport/` | Files / photo import |

#### Steps

1. Add `<Screen>ViewModel.swift` next to the view: `@MainActor @Observable`, use cases through `@Injected`.
2. In the view, replace `FakeData…` with view-model state; keep the layout (visual finish is F16).
3. Loading, empty (`DSEmptyState`) and error states; previews for each.
4. Delete this feature's `Fake*` types from `Core/Fakes/FakeData.swift` once nothing uses them.

## 4. Real data — Import and pins

<details open>
<summary><b>4.1 Floor plan import and storage</b></summary>

- **Goal:** import PDF/image plans, hashed, tiled on demand.
- **Spec:** [11](../feature-docs/01-field-work.md#11-floor-plans-and-issue-pins)

#### Steps

1. Multi-page PDF → one `PlanSheet` per chosen page.
2. Reject encrypted / oversized files with a reason.

</details>

<details open>
<summary><b>4.2 Pin coordinates and persistence</b></summary>

- **Goal:** one pin per issue in 0…1 coordinates; moves audited.
- **Spec:** [11](../feature-docs/01-field-work.md#11-floor-plans-and-issue-pins)

</details>

## Tests (after the feature works)

**3. View models — Wire the Plans screens**

- 60 fps pan / zoom with 50 pins

**4. Real data — Import and pins**

- Oversized and encrypted imports rejected
- A0 peak memory under 150 MB
- `planPoint` round-trip through zoom / pan
- Sheet delete blocked while pins exist

## Feature done

| Check | How |
|---|---|
| Demo | Pins on a real floor plan |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F08 steps ticked |

