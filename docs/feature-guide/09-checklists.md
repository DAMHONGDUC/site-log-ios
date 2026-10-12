# F09 — Checklists

<dl><dd>

- F09 · 10h · skeleton guide — full code is added when this feature starts.

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain — Checklist types](#1-domain--checklist-types)
4. [2. Fake data — In-memory checklists](#2-fake-data--in-memory-checklists)
5. [3. View models — Wire the Checklists screens](#3-view-models--wire-the-checklists-screens)
6. [4. Real data — Templates and results](#4-real-data--templates-and-results)
7. [Tests (after the feature works)](#tests-after-the-feature-works)
8. [Feature done](#feature-done)

</dd></dl>

## Overview

<dl><dd>

- **Goal:** Checklists end to end: Domain → fake data → view models → real data → tests.
- **Demo:** checklist run in a room; a Fail creates one prefilled issue.
- **Spec:** [13](../feature-docs/01-field-work.md#13-checklist-templates)
- **Starts from:** the skeleton screens (~30% of Figma) that read `App/Fakes/FakeData.swift`.
- **Fakes:** only in `Packages/DataLayer/Sources/DataLayer/Fakes/`, registered in `AppDependencies`; the dev menu seeds / clears them through `FakeDevDataActions`.
- **File tags:** <b class="tag-new">New</b> create the file · <b class="tag-edit">Edit</b> change only the part shown.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--checklist-types) | Domain | 1h | not start | Checklist types |
| [2](#2-fake-data--in-memory-checklists) | Fake data | 1h | not start | In-memory checklists |
| [3](#3-view-models--wire-the-checklists-screens) | View models | 4h | not start | Wire the Checklists screens |
| [4](#4-real-data--templates-and-results) | Real data | 4h | not start | Templates and results |

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
├── DomainLayer/Sources/DomainLayer/Checklists/          # 1: template, item, run, result
├── DataLayer/Sources/DataLayer/Fakes/         # 2: InMemoryChecklistRepository with built-in templates
└── DataLayer/Sources/DataLayer/Repositories/  # 4: seeded templates, run results
SiteLog/
└── Presentation/Checklists/                   # 3: TemplatePicker, ChecklistRun, ChecklistDone
```

</dd></dl>

## 1. Domain — Checklist types

<dl><dd>

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Packages/DomainLayer/Sources/DomainLayer/Checklists/` | Template, item, run, result; answer use case (Fail → issue through F05) |

</dd></dl>

## 2. Fake data — In-memory checklists

<dl><dd>

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Packages/DataLayer/Sources/DataLayer/Fakes/InMemoryChecklistRepository.swift` | Templates and runs |
| <b class="tag-edit">Edit</b> | `SiteLog/App/AppDependencies.swift` | Registers the fake; the real step only changes this line |

#### Steps

<dl><dd>

1. Implement the Domain protocol as an `actor` that keeps everything in memory.
2. Seed it with “Finishing handover” (22 items) and 5 other templates — move the values out of `App/Fakes/FakeData.swift`.
3. Add `reset()` (empty) and `seed()`; `FakeDevDataActions` calls them from the dev menu.
4. Register it in `AppDependencies`.

</dd></dl>

</dd></dl>

## 3. View models — Wire the Checklists screens

<dl><dd>

| Action | Skeleton folder | View model work |
|---|---|---|
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Checklists/TemplatePicker/` | K1: resume, recent, all |
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Checklists/ChecklistRun/` | K2: one tap per item, “14 of 22” |
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Checklists/ChecklistDone/` | K4: result sentence, issues sent |

#### Steps

<dl><dd>

1. Add `<Screen>ViewModel.swift` next to the view: `@MainActor @Observable`, use cases through `@Injected`.
2. In the view, replace `FakeData…` with view-model state; keep the layout (visual finish is F16).
3. Loading, empty (`SDEmptyState`) and error states; previews for each.
4. Delete this feature's `Fake*` types from `App/Fakes/FakeData.swift` once nothing uses them.

</dd></dl>

</dd></dl>

## 4. Real data — Templates and results

<dl><dd>

- **Goal:** seeded built-ins; runs keep their own results; fail → prefilled issue.
- **Spec:** [13](../feature-docs/01-field-work.md#13-checklist-templates)

#### Steps

<dl><dd>

1. Built-ins fork on edit; JSON import validated.

</dd></dl>

</dd></dl>

## Tests (after the feature works)

<dl><dd>

**4. Real data — Templates and results**

- Fail creates one issue
- Template edit leaves completed runs unchanged

</dd></dl>

## Feature done

<dl><dd>

| Check | How |
|---|---|
| Demo | Checklist run; Fail creates one issue |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F09 steps ticked |

</dd></dl>
