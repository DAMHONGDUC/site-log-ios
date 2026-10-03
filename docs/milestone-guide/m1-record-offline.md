# M1 — Record offline

- M1 — Record offline · 56h · skeleton guide.

## Contents

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [P08 · Entities, protocols, use cases, fakes](#p08--entities-protocols-use-cases-fakes)
4. [P09 · SwiftData schema and repositories](#p09--swiftdata-schema-and-repositories)
5. [P10 · Schema versioning and migrations](#p10--schema-versioning-and-migrations)
6. [P11 · Bulk-generate and import locations](#p11--bulk-generate-and-import-locations)
7. [P12 · Camera session and permissions](#p12--camera-session-and-permissions)
8. [P13 · Write to disk and SHA-256](#p13--write-to-disk-and-sha-256)
9. [P14 · P1 project list, P2 new project](#p14--p1-project-list-p2-new-project)
10. [P15 · P3 project overview, P4 start session](#p15--p3-project-overview-p4-start-session)
11. [P16 · P5 walkthrough, P6 generate, P7 room](#p16--p5-walkthrough-p6-generate-p7-room)
12. [P17 · C1 camera screen on a fake session](#p17--c1-camera-screen-on-a-fake-session)
13. [P18 · Real logic behind the screens](#p18--real-logic-behind-the-screens)
14. [Milestone done](#milestone-done)

## Overview

- **Goal:** build the project → session → location tree and capture hashed photos, fully offline.
- **Demo:** project → 80 locations → photo captured and hashed, **in airplane mode**.
- **Specs:** [00 §3 Data model](../feature-docs/00-overview.md#3-data-model), [01](../feature-docs/01-field-work.md#01-projects-sessions-locations), [02](../feature-docs/01-field-work.md#02-capture-pipeline)
- **Status:** skeleton — parts, files, order, tests. Full, tested code is added when this milestone starts, built on the real code from the milestone before.

| Part | Track | Hours | Status | What |
|---|---|---|---|---|
| [P08](#p08--entities-protocols-use-cases-fakes) | `Contract` | 5h | not start | Entities, protocols, use cases, fakes |
| [P09](#p09--swiftdata-schema-and-repositories) | `Logic` | 7h | not start | SwiftData schema and repositories |
| [P10](#p10--schema-versioning-and-migrations) | `Logic` | 8h | not start | Schema versioning and migrations |
| [P11](#p11--bulk-generate-and-import-locations) | `Logic` | 3h | not start | Bulk-generate and import locations |
| [P12](#p12--camera-session-and-permissions) | `Logic` | 6h | not start | Camera session and permissions |
| [P13](#p13--write-to-disk-and-sha-256) | `Logic` | 5h | not start | Write to disk and SHA-256 |
| [P14](#p14--p1-project-list-p2-new-project) | `UI` | 4h | not start | P1 project list, P2 new project |
| [P15](#p15--p3-project-overview-p4-start-session) | `UI` | 4h | not start | P3 project overview, P4 start session |
| [P16](#p16--p5-walkthrough-p6-generate-p7-room) | `UI` | 6h | not start | P5 walkthrough, P6 generate, P7 room |
| [P17](#p17--c1-camera-screen-on-a-fake-session) | `UI` | 4h | not start | C1 camera screen on a fake session |
| [P18](#p18--real-logic-behind-the-screens) | `Join` | 4h | not start | Real logic behind the screens |

### Order

- P08 contract first.
- Then UI (P14 → P17) on the fakes and Logic (P09 → P13) in parallel.
- P18 joins them: swap fake registrations for SwiftData + capture.

## Target structure

```text
Packages/
├── Domain/Sources/Domain/
│   ├── Projects/        # P08: Project, Session, Location, Capture, repository protocols, use cases
├── Persistence/         # P09–P10: new package, SwiftData models, SchemaV1, migration plan
├── DataLayer/Sources/DataLayer/Repositories/   # P09: SwiftData*Repository, mappers
└── Capture/             # P12–P13: new package, CaptureSessionControlling, FileHasher
SiteLog/
├── App/Fakes/           # P08: InMemoryProjectRepository, FakeCaptureSession
└── Presentation/
    ├── Projects/ProjectList/, NewProject/, ProjectOverview/, StartSession/   # P14–P15
    ├── Sessions/Walkthrough/, GenerateLocations/, Room/                      # P16
    └── Capture/Camera/                                                        # P17
```

## P08 · Entities, protocols, use cases, fakes

- **Goal:** one contract both tracks build against: Domain entities, repository protocols, one use case per action, in-memory fakes and preview data.
- **Spec:** [00 §3.2](../feature-docs/00-overview.md#32-entities)

| File | Holds |
|---|---|
| `Domain/Projects/Entities.swift` | `Project`, `Session` (state machine), `Location` (depth ≤ 3), `Capture` (frozen fields) |
| `Domain/Projects/ProjectRepository.swift` … | One protocol per aggregate: project, session, location, capture |
| `Domain/Projects/UseCases/` | `CreateProjectUseCase`, `StartSessionUseCase`, `GenerateLocationsUseCase`, `RecordCaptureUseCase`, … |
| `SiteLog/App/Fakes/` | `InMemory*Repository` + `PreviewData` (realistic: “Riverside Tower B”, 37 of 82 rooms) |

### Steps

1. Write entities as plain `Sendable` structs (no SwiftData in Domain).
2. Write protocols with `async throws` methods.
3. Register fakes in `AppDependencies`.
4. Rows for lists: `LocationRow` with counts from one batched call.

### Tests

- Session state: `closed` rejects `addCapture`; `exported` read-only
- Location depth 4 rejected
- Use cases against fakes

### Done when

- UI track can build every M1 screen without SwiftData or a camera

## P09 · SwiftData schema and repositories

- **Goal:** SwiftData models in a new `Persistence` package and repository implementations in `DataLayer`.
- **Spec:** [00 §3.4](../feature-docs/00-overview.md#34-schema-versioning)

| File | Holds |
|---|---|
| `Packages/Persistence/` | `@Model` types, `#Unique`/`#Index` (location code per project, sha256 per project) |
| `DataLayer/Repositories/SwiftData*Repository.swift` | Implements the P08 protocols; mappers model ↔ entity |

### Steps

1. Create the package (Xcode: File → New → Package; then add to `project.yml` `packages`).
2. Write models mirroring the entities; store relative file paths.
3. Write repositories with a `@ModelActor` for writes.
4. Cascade delete project → sessions, locations, plans.

### Tests

- Repositories over an in-memory `ModelContainer`
- Cascade delete leaves no orphans
- Uniques reject duplicates

## P10 · Schema versioning and migrations

- **Goal:** `VersionedSchema` + `SchemaMigrationPlan` from day one.
- **Spec:** [00 §3.4](../feature-docs/00-overview.md#34-schema-versioning)

| File | Holds |
|---|---|
| `Persistence/Schema/SchemaV1.swift` | First versioned schema |
| `Persistence/Schema/MigrationPlan.swift` | Stages list (empty until V2) |
| `Persistence/Tests/Fixtures/` | A 100-location `SchemaV1` store |

### Steps

1. Wrap models in `SchemaV1`.
2. Add the startup step `DatabaseStep` (blocks launch) to `StartupSequence`.
3. Commit a fixture store for migration tests.

### Tests

- Open the fixture store with the current plan
- Store file has `.complete` protection

## P11 · Bulk-generate and import locations

- **Goal:** generate 80 locations from a template in one transaction.
- **Spec:** [01](../feature-docs/01-field-work.md#01-projects-sessions-locations)

| File | Holds |
|---|---|
| `Domain/.../GenerateLocationsUseCase.swift` | Template → preview (first 5, last 3, total) → insert |
| `LocationTemplateLimits` | `maxGeneratedPerBatch` 2000, `maxDepth` 3 |

### Steps

1. Pure template expansion in Domain (`"{floor}-{unit:02}"`).
2. Reject duplicates by name; cap the batch.
3. One repository call inserts everything.

### Tests

- 1 floor, 1 unit, collisions
- Batch cap
- Kill mid-generation leaves no partial records

## P12 · Camera session and permissions

- **Goal:** one `AVCaptureSession` behind `CaptureSessionControlling`, testable without a camera.
- **Spec:** [02.1](../feature-docs/01-field-work.md#021-session-and-state)

| File | Holds |
|---|---|
| `Packages/Capture/CaptureSessionControlling.swift` | Protocol: configure, start, stop, capturePhoto |
| `Capture/AVCaptureSessionController.swift` | Real implementation on `sessionQueue` |
| `Capture/CaptureState.swift` | `idle → configuring → ready → capturingPhoto` |

### Steps

1. Never `startRunning()` on main.
2. Camera, mic, location permissions asked separately.
3. Add `NSCameraUsageDescription` etc. via `project.yml` `INFOPLIST_KEY_*`.

### Tests

- State machine rejects recording during photo
- Interruption finalizes once

## P13 · Write to disk and SHA-256

- **Goal:** each photo written to `media/…` and hashed before the DB row exists.
- **Spec:** [02.2](../feature-docs/01-field-work.md#022-metadata-and-hashing)

| File | Holds |
|---|---|
| `Capture/FileHasher.swift` | Streams SHA-256 in 1 MB chunks |
| `Capture/MediaStore.swift` | Path `media/<project>/<session>/<capture>.<ext>`, `.completeUnlessOpen`, excluded from backup |

### Steps

1. Write → close → hash → insert row (no row without a hash).
2. GPS older than `locationStaleAfter` is `nil`.

### Tests

- Hash against known vectors and `shasum` on 200 MB
- Stale GPS → `nil`

## P14 · P1 project list, P2 new project

- **Goal:** project list with the in-progress walkthrough on top; new-project sheet.
- **Spec:** Mockups P1, P2

| File | Holds |
|---|---|
| `Presentation/Projects/ProjectList/` | View + ViewModel |
| `Presentation/Projects/NewProject/` | Sheet + ViewModel |

### Steps

1. Build on fakes + `PreviewData`; DesignSystem rows and buttons only.
2. Empty state with `DSEmptyState`.
3. Snapshot: light, dark, `accessibility3`.

### Tests

- View models against fakes (`@Suite(.container)`)
- Snapshots

## P15 · P3 project overview, P4 start session

- **Goal:** project detail (Sessions · Locations · Plans) and the start-session sheet.
- **Spec:** Mockups P3, P4

| File | Holds |
|---|---|
| `Presentation/Projects/ProjectOverview/` | Segmented tabs, sentence summary |
| `Presentation/Projects/StartSession/` | Inspector, weather, note |

### Steps

1. Summary written as a sentence (“14 open issues, 2 of them overdue”).
2. Start → `StartSessionUseCase` on the fake.

### Tests

- View models
- Snapshots

## P16 · P5 walkthrough, P6 generate, P7 room

- **Goal:** the survey screen with badges, bulk generation and the room screen.
- **Spec:** Mockups P5, P6, P7

| File | Holds |
|---|---|
| `Presentation/Sessions/Walkthrough/` | Location tree + filter chips + badges |
| `Presentation/Sessions/GenerateLocations/` | Template form + preview |
| `Presentation/Sessions/Room/` | Room detail, camera entry in the lower half |

### Steps

1. Badge counts from one batched call per screen.
2. 500-row list stays at 60 fps (measure in Instruments).

### Tests

- View models
- Snapshots
- Preview shows first 5 / last 3 / total

## P17 · C1 camera screen on a fake session

- **Goal:** camera UI driven by a fake `CaptureSessionControlling`.
- **Spec:** Mockup C1

| File | Holds |
|---|---|
| `Presentation/Capture/Camera/` | Preview (`UIViewRepresentable`), shutter in a bottom toolbar, thumbnail strip |
| `App/Fakes/FakeCaptureSession.swift` | Returns a bundled image |

### Steps

1. Hi-vis yellow only on the shutter.
2. Never blocks on upload state.

### Tests

- View model state transitions
- Snapshot

## P18 · Real logic behind the screens

- **Goal:** swap fakes for SwiftData repositories and the real camera; run the airplane-mode demo.

| File | Holds |
|---|---|
| `SiteLog/App/AppDependencies.swift` | Register `SwiftData*Repository`, `AVCaptureSessionController` |

### Steps

1. Change registrations only; no view code changes.
2. Airplane mode on a real device: project → 80 locations → capture.
3. Tick P08–P18 in ROADMAP.

### Done when

- 50 photos with flat memory
- Relaunch shows every capture with its hash

## Milestone done

| Check | How |
|---|---|
| Zero warnings, tests green | `bundle exec fastlane test`; CI green |
| Demo on device | Airplane mode: project → 80 locations → hashed photo |
| Roadmap | P08–P18 ticked |
