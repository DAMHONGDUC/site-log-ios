# F05 — Issues and before/after

<dl><dd>

- F05 · 21h · skeleton guide — full code is added when this feature starts.

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain — Issue entities and use cases](#1-domain--issue-entities-and-use-cases)
4. [2. Fake data — In-memory issues](#2-fake-data--in-memory-issues)
5. [3. View models — Wire the Issues screens](#3-view-models--wire-the-issues-screens)
6. [4. Real data — Issue logic and dictation](#4-real-data--issue-logic-and-dictation)
7. [Tests (after the feature works)](#tests-after-the-feature-works)
8. [Feature done](#feature-done)

</dd></dl>

## Overview

<dl><dd>

- **Goal:** Issues and before/after end to end: Domain → fake data → view models → real data → tests.
- **Demo:** issue logged from the camera, re-checked next session, closed as a before/after pair.
- **Spec:** [03](../feature-docs/01-field-work.md#03-issues-and-before-after-pairing), [12.3 dictation](../feature-docs/01-field-work.md#123-dictation-and-voice-notes)
- **Starts from:** the skeleton screens (~30% of Figma) that read `App/Fakes/FakeData.swift`.
- **Fakes:** only in `Packages/DataLayer/Sources/DataLayer/Fakes/`, registered in `AppDependencies`; the dev menu seeds / clears them through `FakeDevDataActions`.
- **File tags:** <b class="tag-new">New</b> create the file · <b class="tag-edit">Edit</b> change only the part shown.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--issue-entities-and-use-cases) | Domain | 2h | not start | Issue entities and use cases |
| [2](#2-fake-data--in-memory-issues) | Fake data | 1h | not start | In-memory issues |
| [3](#3-view-models--wire-the-issues-screens) | View models | 7h | not start | Wire the Issues screens |
| [4](#4-real-data--issue-logic-and-dictation) | Real data | 11h | not start | Issue logic and dictation |

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
├── DomainLayer/Sources/DomainLayer/Issues/              # 1: Issue, IssuePairing, PairIssuesUseCase (pure)
├── DataLayer/Sources/DataLayer/Fakes/         # 2: InMemoryIssueRepository
└── DataLayer/Sources/DataLayer/Repositories/  # 4: SwiftDataIssueRepository
SiteLog/
└── Presentation/Issues/                       # 3: IssueSheet, IssueList, IssueDetail, VerificationCamera, OutcomePicker
```

</dd></dl>

## 1. Domain — Issue entities and use cases

<dl><dd>

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Packages/DomainLayer/Sources/DomainLayer/Issues/` | `Issue`, `IssuePairing`, `PairIssuesUseCase` (pure), log / close / carry-over use cases |

</dd></dl>

## 2. Fake data — In-memory issues

<dl><dd>

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Packages/DataLayer/Sources/DataLayer/Fakes/InMemoryIssueRepository.swift` | Issues per project and room |
| <b class="tag-edit">Edit</b> | `SiteLog/App/AppDependencies.swift` | Registers the fake; the real step only changes this line |

#### Steps

<dl><dd>

1. Implement the Domain protocol as an `actor` that keeps everything in memory.
2. Seed it with the 5 sample issues (critical, major, minor, one closed) — move the values out of `App/Fakes/FakeData.swift`.
3. Add `reset()` (empty) and `seed()`; `FakeDevDataActions` calls them from the dev menu.
4. Register it in `AppDependencies`.

</dd></dl>

</dd></dl>

## 3. View models — Wire the Issues screens

<dl><dd>

| Action | Skeleton folder | View model work |
|---|---|---|
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Issues/IssueSheet/` | C2 / K3: severity default Major, assignee, due, phrases |
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Issues/IssueList/` | C5: Open / Closed / All, grouped by level; tab badge count |
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Issues/IssueDetail/` | C6: facts, Mark up, Re-check now |
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Issues/VerificationCamera/` | C3: ghost opacity from `IssueDefaults.overlayOpacity` |
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Issues/OutcomePicker/` | C4: close / keep open / raise |

#### Steps

<dl><dd>

1. Add `<Screen>ViewModel.swift` next to the view: `@MainActor @Observable`, use cases through `@Injected`.
2. In the view, replace `FakeData…` with view-model state; keep the layout (visual finish is F16).
3. Loading, empty (`DSEmptyState`) and error states; previews for each.
4. Delete this feature's `Fake*` types from `App/Fakes/FakeData.swift` once nothing uses them.

</dd></dl>

</dd></dl>

## 4. Real data — Issue logic and dictation

<dl><dd>

<details open>
<summary><strong>4.1 Issue CRUD, carry-over, pairing</strong></summary>
<dl><dd>

- **Goal:** log issues, surface open ones next session, close by verification photo.
- **Spec:** [03.1–03.2](../feature-docs/01-field-work.md#031-flows)

#### Steps

<dl><dd>

1. Closing creates a new `.verified` issue and links the old one; originals never mutated.
2. Upload priority: critical 100 · major 50 · minor 10.

</dd></dl>
</details>

<details open>
<summary><strong>4.2 Phrase library, dictation, voice notes</strong></summary>
<dl><dd>

- **Goal:** on-device dictation and a usage-sorted phrase library.
- **Spec:** [12.3](../feature-docs/01-field-work.md#123-dictation-and-voice-notes)

</dd></dl>

#### Steps

<dl><dd>

1. `SFSpeechRecognizer` with `requiresOnDeviceRecognition = true`; vi + en.
2. Voice note = audio `Capture`.

</dd></dl>
</details>

</dd></dl>

</dd></dl>

## Tests (after the feature works)

<dl><dd>

**1. Domain — Issue entities and use cases**

- Pairing with 0 / 1 / n open issues

**4. Real data — Issue logic and dictation**

- Closing never mutates prior captures
- Delete-with-open-issues rejected
- Phrase ordering tie-break
- Dictation in airplane mode

</dd></dl>

## Feature done

<dl><dd>

| Check | How |
|---|---|
| Demo | Issue → re-check → before/after pair shown on the issue |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F05 steps ticked |

</dd></dl>
