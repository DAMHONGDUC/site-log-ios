# F02 — Projects, sessions, locations

- F02 · 31h · skeleton guide — full code is added when this feature starts.

## Contents

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain — Entities, protocols, use cases](#1-domain--entities-protocols-use-cases)
4. [2. Fake data — In-memory repositories](#2-fake-data--in-memory-repositories)
5. [3. View models — Wire the Projects screens](#3-view-models--wire-the-projects-screens)
6. [4. Real data — SwiftData](#4-real-data--swiftdata)
7. [Tests (after the feature works)](#tests-after-the-feature-works)
8. [Feature done](#feature-done)

## Overview

- **Goal:** Projects, sessions, locations end to end: Domain → fake data → view models → real data → tests.
- **Demo:** project → 80 generated locations → walkthrough, all offline and kept after relaunch.
- **Spec:** [01](../feature-docs/01-field-work.md#01-projects-sessions-locations), [00 §3 Data model](../feature-docs/00-overview.md#3-data-model)
- **Starts from:** the skeleton screens (~30% of Figma) that read `Core/Fakes/FakeData.swift`.
- **Fakes:** only in `SiteLog/Data/Fakes/`, registered in `AppDependencies`; the dev menu seeds / clears them through `FakeDevDataActions`.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--entities-protocols-use-cases) | Domain | 4h | not start | Entities, protocols, use cases |
| [2](#2-fake-data--in-memory-repositories) | Fake data | 2h | not start | In-memory repositories |
| [3](#3-view-models--wire-the-projects-screens) | View models | 10h | not start | Wire the Projects screens |
| [4](#4-real-data--swiftdata) | Real data | 15h | not start | SwiftData |

### Order

- Steps run top to bottom; the app runs after every step.
- Real data changes only registrations in `AppDependencies`, never views or view models.
- Tests come last, once the feature works end to end.

## Target structure

```text
SiteLog/
├── Domain/Projects/            # 1: Project, Session, Location, Capture, protocols, use cases
├── Data/Fakes/                 # 2: InMemoryProjectRepository (+ session, location)
├── Data/Repositories/          # 4: SwiftData*Repository, mappers
├── DataSources/Persistence/    # 4: @Model types, SchemaV1, migration plan
└── Presentation/Projects/      # 3: ProjectList, NewProject, ProjectDetail, StartSession,
                                #    Survey, Room, BulkLocations, CloneTree, EndSession
```

## 1. Domain — Entities, protocols, use cases

| File | Holds |
|---|---|
| `Domain/Projects/Entities.swift` | `Project`, `Session` (state machine), `Location` (depth ≤ 3), `Capture` (frozen fields) |
| `Domain/Projects/*Repository.swift` | One protocol per aggregate: project, session, location, capture |
| `Domain/Projects/UseCases/` | `CreateProjectUseCase`, `StartSessionUseCase`, `GenerateLocationsUseCase`, `CloneLocationTreeUseCase`, … |

#### Steps

1. Entities are plain `Sendable` structs; no SwiftData in Domain.
2. Protocols use `async throws`.
3. `GenerateLocationsUseCase` is pure: template `"{floor}-{unit:02}"` → preview (first 5, last 3, total); cap `maxGeneratedPerBatch` 2000, `maxDepth` 3; duplicates rejected.
4. List rows (`LocationRow`) get their counts from one batched call.

## 2. Fake data — In-memory repositories

| File | Holds |
|---|---|
| `SiteLog/Data/Fakes/InMemoryProjectRepository.swift` | Projects, sessions, locations in memory (one actor per aggregate is fine) |
| `SiteLog/App/AppDependencies.swift` | Registers the fake; the real step only changes this line |

#### Steps

1. Implement the Domain protocol as an `actor` that keeps everything in memory.
2. Seed it with “Riverside Tower B”, 37 of 82 rooms, 4 sessions — move the values out of `Core/Fakes/FakeData.swift`.
3. Add `reset()` (empty) and `seed()`; `FakeDevDataActions` calls them from the dev menu.
4. Register it in `AppDependencies`.

## 3. View models — Wire the Projects screens

| Skeleton folder | View model work |
|---|---|
| `Presentation/Projects/ProjectList/` | P1: projects + walkthrough in progress |
| `Presentation/Projects/NewProject/` | P2: create through `CreateProjectUseCase` |
| `Presentation/Projects/ProjectDetail/` | P3: Sessions · Locations tabs, sentence summary |
| `Presentation/Projects/StartSession/` | P4: start through `StartSessionUseCase` |
| `Presentation/Projects/Survey/` | P5: rooms per unit, filter chips, badge counts |
| `Presentation/Projects/Room/` | P7: room detail, photos, checklist row |
| `Presentation/Projects/BulkLocations/` | P6: template form + preview from the use case |
| `Presentation/Projects/CloneTree/` | Copy a location tree |
| `Presentation/Projects/EndSession/` | R1: session summary |

#### Steps

1. Add `<Screen>ViewModel.swift` next to the view: `@MainActor @Observable`, use cases through `@Injected`.
2. In the view, replace `FakeData…` with view-model state; keep the layout (visual finish is F16).
3. Loading, empty (`DSEmptyState`) and error states; previews for each.
4. Delete this feature's `Fake*` types from `Core/Fakes/FakeData.swift` once nothing uses them.
5. Summaries are sentences (“14 open issues, 2 of them overdue”).
6. A 500-row survey list stays at 60 fps.

## 4. Real data — SwiftData

### SwiftData schema and repositories

- **Goal:** SwiftData models in `DataSources/Persistence/` and repository implementations in `Data/`.
- **Spec:** [00 §3.4](../feature-docs/00-overview.md#34-schema-versioning)

| File | Holds |
|---|---|
| `SiteLog/DataSources/Persistence/` | `@Model` types, `#Unique`/`#Index` (location code per project, sha256 per project) |
| `SiteLog/Data/Repositories/SwiftData*Repository.swift` | Implements the step 1 protocols; mappers model ↔ entity |

#### Steps

1. Create the folder `SiteLog/DataSources/Persistence/`; types inside are `nonisolated`.
2. Write models mirroring the entities; store relative file paths.
3. Write repositories with a `@ModelActor` for writes.
4. Cascade delete project → sessions, locations, plans.

### Schema versioning and migrations

- **Goal:** `VersionedSchema` + `SchemaMigrationPlan` from day one.
- **Spec:** [00 §3.4](../feature-docs/00-overview.md#34-schema-versioning)

| File | Holds |
|---|---|
| `Persistence/Schema/SchemaV1.swift` | First versioned schema |
| `Persistence/Schema/MigrationPlan.swift` | Stages list (empty until V2) |
| `Persistence/Tests/Fixtures/` | A 100-location `SchemaV1` store |

#### Steps

1. Wrap models in `SchemaV1`.
2. Add the startup step `DatabaseStep` (blocks launch) to `StartupSequence`.
3. Commit a fixture store for migration tests.

## Tests (after the feature works)

**1. Domain — Entities, protocols, use cases**

- Session state: `closed` rejects `addCapture`; `exported` read-only
- Location depth 4 rejected
- Generate: 1 floor, 1 unit, collisions, batch cap

**3. View models — Wire the Projects screens**

- View models against the fakes (`@Suite(.container)`)
- Bulk preview shows first 5 / last 3 / total

**4. Real data — SwiftData**

- Repositories over an in-memory `ModelContainer`
- Cascade delete leaves no orphans
- Uniques reject duplicates
- Open the fixture store with the current plan
- Store file has `.complete` protection

## Feature done

| Check | How |
|---|---|
| Demo | Airplane mode: project → 80 locations → walkthrough; relaunch keeps everything |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F02 steps ticked |
