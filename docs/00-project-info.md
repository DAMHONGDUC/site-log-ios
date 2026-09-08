# 00 — Project info

Everything that is not a single feature: product, market, data model, architecture, data flows,
configuration, CI, and conventions. Feature specs are `01`–`13`.

**Contents** — 1. [Product](#1-product) · 2. [Market](#2-market) · 3. [Data model](#3-data-model) · 4. [Architecture](#4-architecture) · 5. [Data flows](#5-data-flows) · 6. [Infrastructure](#6-infrastructure) · 7. [Schedule](#7-schedule) · 8. [Conventions](#8-conventions) · 9. [Feature specs](#9-feature-specs)

## 1. Product

Offline-first iOS app for recording construction site conditions. Output: a signed PDF inspection
report.

Users: site supervisors, subcontractors, apartment handover teams.

```
Create project → start session → walk floors/rooms, capture + log issues
→ reach WiFi, background upload → export signed PDF report
```

### 1.1 Positioning

Every competitor loses evidence the same three ways:

- Uploads stall, or complete with photos missing.
- Photos vanish on reload; comments fail silently when the device reconnects.
- Sync fails with no explanation the user can act on.

SiteLog assumes the network is bad and is built around that.

### 1.2 Context constraints

| Constraint | Consequence |
|---|---|
| Sites, basements, alleys have weak or no signal | Every write path completes offline |
| 150–250 files and several GB per session | Upload survives suspend, termination, network loss |
| User closes the app and keeps walking | No state lives only in RAM |
| The PDF is the paid deliverable | Never truncate, never silently drop images |

### 1.3 Core rule

- `Capture` is immutable after creation; only descriptive metadata is editable.
- Each carries a `sha256` computed after the file closes, before the DB write.
- Annotations are a separate vector layer, so markup never invalidates a hash.

### 1.4 Stack

| Area | Choice |
|---|---|
| UI | SwiftUI, iOS 17+ |
| Architecture | MVVM, SPM modules |
| Concurrency | Swift Concurrency — `actor` for upload, `@MainActor` for view models |
| Local store | SwiftData |
| Media | AVFoundation (`AVCaptureSession`, `AVAssetWriter`) |
| Plans | PDFKit + `CATiledLayer` |
| Crypto | CryptoKit + iOS Data Protection, keys in Keychain |
| External devices | CoreBluetooth |
| Transport | Hand-written `URLSession` background configuration |
| Object storage | Cloudflare R2, S3 multipart + presigned URLs |
| Auth / crash | Firebase (Auth, Crashlytics) — **no Firestore** |
| All application data | PostgreSQL behind the backend ([14](14-backend.md)) |
| Backend | Node 22 + TypeScript + Fastify, PostgreSQL 16, raw SQL ([14](14-backend.md)) |

### 1.5 Non-goals

| Excluded | Reason |
|---|---|
| Firebase Storage `putFile()` | Cannot reattach after cold launch, cannot control `isDiscretionary` or priority |
| `UIImagePickerController` / `PhotosPicker` | Hides `AVCaptureSession` control; a hash only means something for a file the app produced |
| Third-party upload libraries | The transfer engine is the core of the product |
| Firebase touching file bytes or data | Identity and crash reporting only |
| Burning annotations into original pixels | Destroys the hash |
| RFIs, scheduling, budgets, CAD | Different product |

## 2. Market

Research date: September 2026. Basis for features 11–13 and the amendments to 02, 03, 05.

### 2.1 Competitive set

| App | Position | Notable |
|---|---|---|
| Fieldwire (Hilti) | Category leader, drawing-centric | Pin to drawing, assign to sub, offline markup |
| PlanGrid / Autodesk Build | Enterprise | Reviewers cite cost and a steep learning curve |
| SnagR | UK/EU defect documentation | Pins on drawings, custom workflows, logging speed |
| IssMan | Snag lists + sharing | Annotated photos and notes per issue |
| SnagPal | Free iOS-only snagging | Photo → annotate → pin → branded PDF, fully offline |
| PlanInspect | DWG/PDF plan viewer | Pin notes with photos at plan coordinates |
| CompanyCam | Jobsite photo documentation | Photo-first, auto-organized by project |
| Timemark | Photo proof of work | Tamper-resistant timestamp, visible stamp, per-photo code |
| GoAudits / SafetyCulture | Checklist audits | Template inspections, scoring, offline |

### 2.2 Table stakes that were missing

| Feature | Evidence | Decision |
|---|---|---|
| Pin an issue onto a floor plan | Fieldwire, SnagR, IssMan, SnagPal, PlanInspect all lead with it | **Add** → [11](11-floorplan-pins.md) |
| Photo annotation | Universal; SnagPal advertises "annotate in under 10 seconds" | **Add** → [12](12-annotation.md) |
| Assignee / responsible subcontractor | Every punch list product; reports group by contractor | **Add** → [03](03-issue-tracking.md) |
| Branded PDF | Even the free SnagPal ships it | **v1** → [05](05-reporting.md) |
| Excel / CSV export | Cited alongside PDF everywhere | **Add** → [05](05-reporting.md) |
| Voice notes + dictation | Snagging apps advertise audio memo per snag | **Add** → [03](03-issue-tracking.md), [12](12-annotation.md) |
| Checklist templates | GoAudits, SafetyCulture; VN handover guides publish room-by-room checklists | **Add** → [13](13-checklists.md) |
| Visible timestamp/GPS stamp | Timemark's entire product | **Add as derived copy** → [12](12-annotation.md) |

### 2.3 Documented user pain → SiteLog's answer

| Reported pain | Answer |
|---|---|
| "Uploads stall or complete with photos missing" | Per-part state machine, ETag verification, server hash cross-check ([04](04-upload-engine.md), [10](10-realtime-progress.md)) |
| "Photos vanish on reload; comments fail silently" | Local store is truth; nothing deleted until `synced` and confirmed ([09](09-diagnostics.md)) |
| "Sync failed with no explanation" | Plain-language reason + self-service redacted diagnostic bundle ([09](09-diagnostics.md)) |
| "App slows or crashes with many photos" | Downsampled page rendering, per-page autorelease, streaming hashes ([05](05-reporting.md), [02](02-capture.md)) |
| "Sync lags with large plan sets" | Plan tiles cached on disk, rendered on demand ([11](11-floorplan-pins.md)) |
| "Too expensive, steep learning curve" | Single-operator scope; no RFIs, schedules, org hierarchy |

### 2.4 Differentiator: verifiable capture

- Timemark sells tamper-resistant timestamps plus a per-photo verification code.
- SiteLog's original specs used `Date()` — spoofed by changing the device clock in Settings.
- That undermines the chain-of-custody claim the whole app rests on. Fixed by:

1. Record device wall clock, monotonic uptime, and a signed server offset when reachable.
2. Store a `timeConfidence` and print it in the report — never claim absent precision.
3. Countersign the capture hash server-side at upload; the report prints a resolvable code.

Detail: [12](12-annotation.md) §7–8.

### 2.5 Vietnamese handover market

| Observation | Consequence |
|---|---|
| A signed handover record between both parties gives legal standing in a dispute | The signature page is load-bearing, not decoration |
| Buyers are advised not to sign until every defect is fixed and re-inspected | The before/after loop ([03](03-issue-tracking.md)) is the legally central feature |
| Inspection is checklist-driven and room-by-room | Templates ([13](13-checklists.md)) match how the market already works |

### 2.6 Explicitly not adopted

| Feature | Why not |
|---|---|
| RFIs, submittals, scheduling, budgets | Procore's category; dilutes every screen |
| Real-time multi-user collaboration | Needs an org and permission model; v2 at the earliest |
| Cloud AI defect detection | No training data, indefensible accuracy in a dispute |
| DWG/CAD viewing | Large parsing surface; PDF and image plans cover this market |

## 3. Data model

### 3.1 Hierarchy

```
Project
 ├ PlanSheet (imported floor plan)          → 11
 ├ ChecklistTemplate                        → 13
 └ Session (survey run)
    └ Location (floor / unit / room)
       ├ ChecklistRun → ChecklistResult     → 13
       └ Capture (photo | video | audio)
          ├ Annotation (vector overlay)     → 12
          └ Issue
                └ PlanPin                   → 11
```

`Location` belongs to `Project`, not `Session` — this is what makes cross-session before/after
pairing possible. Entities for 11–13 are defined in their own specs.

### 3.2 Immutability

| Set | Fields |
|---|---|
| **Frozen after creation** | `id`, `fileURL`, `sha256`, `capturedAt`, `trustedTime`, `latitude`, `longitude`, `deviceModel`, `byteSize`, `kind` |
| Mutable | `label`, `issues`, `sortIndex`, `uploadState`, `remoteKey`, `verificationCode`, `isExcludedFromReport` |

No API deletes a `Capture` from an exported `Session`; hiding sets `isExcludedFromReport` and writes
an audit entry ([07](07-security.md)).

### 3.3 Entities

#### Project

| Field | Type | Note |
|---|---|---|
| `id` | `UUID` | |
| `name`, `address`, `clientName` | `String` | |
| `createdAt` | `Date` | |
| `sessions`, `locations`, `planSheets` | relationships | cascade delete |

#### Session

| Field | Type | Note |
|---|---|---|
| `id` | `UUID` | |
| `startedAt` / `endedAt` | `Date` / `Date?` | nil = open |
| `surveyorName`, `note` | `String` | |
| `state` | `SessionState` | `draft → active → closed → exported` |

`closed` blocks new captures. `exported` is terminal and read-only.

#### Location

| Field | Type | Note |
|---|---|---|
| `id` | `UUID` | Stable across renames |
| `code` | `String` | `"A-12.05"`, `"F3 / R302"` |
| `kind` | `LocationKind` | `.floor` / `.unit` / `.room` |
| `parent` | `Location?` | Self-referencing, max depth 3 |
| `sortIndex` | `Int` | |

#### Capture

| Field | Type | Note |
|---|---|---|
| `id` | `UUID` | |
| `kind` | `CaptureKind` | `.photo` / `.video` / `.audio` |
| `fileURL` | `URL` | **Relative** to the app container |
| `sha256` | `String` | Plaintext hash, before DB write |
| `byteSize` | `Int64` | |
| `capturedAt` | `Date` | Device wall clock |
| `trustedTime` | `TrustedTimestamp` | Clock provenance + confidence ([12](12-annotation.md)) |
| `verificationCode` | `String?` | nil until synced |
| `latitude` / `longitude` | `Double?` | **Nullable** — basements have no GPS |
| `horizontalAccuracy` | `Double?` | Lets the report print "±35 m" instead of implying precision |
| `deviceModel` | `String` | |
| `duration` | `TimeInterval?` | video/audio |
| `measurement` | `Measurement?` | From BLE ([06](06-device-link.md)) |
| `uploadState` | `UploadState` | |
| `remoteKey` | `String?` | R2 key once synced |
| `isExcludedFromReport` | `Bool` | |

App container UUIDs change after reinstall or restore — absolute paths lose all media.

#### Issue

| Field | Type | Note |
|---|---|---|
| `id` | `UUID` | |
| `title`, `detail` | `String` | |
| `severity` | `IssueSeverity` | `.critical` / `.major` / `.minor` |
| `status` | `IssueStatus` | `.open → .inProgress → .resolved → .verified` |
| `dueDate` | `Date?` | |
| `location` | `Location` | Anchored to Location, not Session |
| `assigneeName`, `trade` | `String?` | Free text, autocompleted |
| `planPin` | `PlanPin?` | ([11](11-floorplan-pins.md)) |
| `sourceChecklistResult` | `ChecklistResult?` | ([13](13-checklists.md)) |
| `captures` | `[Capture]` | |
| `resolvedByIssue` | `Issue?` | The later-session issue that verified the fix |

`severity` drives upload priority ([04](04-upload-engine.md)).

### 3.4 UploadState

```
pending → uploading → synced
             ↓  ↑
           failed
```

| State | Meaning |
|---|---|
| `pending` | Written and hashed, not enqueued |
| `uploading` | At least one part in flight |
| `failed` | Retry budget exhausted, awaiting user retry |
| `synced` | Server completed, ETag verified |

`failed` is not terminal and never deletes local files.

### 3.5 Schema versioning

- `VersionedSchema` + `SchemaMigrationPlan` from v1, even with one version.
- Per change: add `SchemaV{n}`, keep `SchemaV{n-1}`, declare a `MigrationStage`
  (`.lightweight` for added optionals, `.custom` when semantics change).
- Test migrations against an old-version fixture store, never an empty one.

## 4. Architecture

### 4.1 Repo layout

```
site_log/
├── App/
│   ├── SiteLogApp.swift              # @main, composition root
│   ├── AppDependencies.swift         # DI container
│   ├── Startup/                      # guarded startup steps
│   ├── Features/
│   │   ├── Projects/ Capture/ Issues/ Plans/ Checklists/
│   │   ├── Auth/ Sync/ Security/ Diagnostics/
│   ├── Resources/                    # assets, localization, seeded templates
│   └── Config/                       # *.xcconfig, Info.plist, entitlements
├── Packages/
│   ├── Core/ DesignSystem/ Persistence/
│   ├── Capture/ UploadKit/ Reporting/ Plans/ DeviceLink/ Realtime/
├── Tools/MockPeripheral/             # macOS BLE simulator
├── Backend/                          # Node.js + Postgres: signing, job store, WebSocket → 14
├── docs/
└── .github/workflows/
```

### 4.2 Package graph

```
                    ┌──────────┐
                    │   App    │  the only place that wires modules
                    └────┬─────┘
       ┌──────────┬──────┴──────┬───────────┬──────────┐
       ▼          ▼             ▼           ▼          ▼
  Persistence  Capture     Reporting     Plans     DeviceLink
       │          │             │           │          │
       └──────────┴──────┬──────┴───────────┘          │
                         ▼                             │
                  ┌────────────┐                       │
                  │    Core    │ ◄─────────────────────┘
                  └────────────┘
   DesignSystem ──► (UI packages only)
   UploadKit   ──► (nothing)      Realtime ──► (nothing)
```

#### Dependency rules

| Rule | Enforcement |
|---|---|
| `Core` imports nothing beyond `Foundation` | CI grep for framework imports |
| `UploadKit` and `Realtime` import nothing from the project | CI builds each standalone |
| `UploadKit` ⊥ `Realtime` | CI removes `Realtime`; app must still build |
| Feature packages never import each other | CI dependency-graph assertion |
| Only `App` imports more than two packages | Code review |
| Cross-module access via `public` surface only | `internal` by default |

#### Module responsibilities

| Module | Owns | Never |
|---|---|---|
| `Core` | Entities, business rules, pairing logic, state merges | Touch disk, network, UI |
| `DesignSystem` | Spacing/color/type tokens, shared components | Contain business logic |
| `Persistence` | Schema, migrations, `ModelActor`s, `UploadStore` impl | Leak `PersistentModel` outward |
| `Capture` | Session, writer, hashing, annotation rendering | Know about projects or issues |
| `UploadKit` | Transfer state machine, chunking, background session | Know what a `Capture` is |
| `Reporting` | Layout engine, PDF/CSV rendering | Fetch data — it receives a snapshot |
| `Plans` | Plan tiling, pin coordinate math | Own issue semantics |
| `DeviceLink` | BLE lifecycle, vendor profiles, parsing | Block capture |
| `Realtime` | WebSocket lifecycle, event decoding | Mutate app state directly |

### 4.3 Layers inside a feature

| Layer | Type | Rules |
|---|---|---|
| View | `SwiftUI.View` | Layout only. No business `if`, no `ModelContext`, no async work |
| ViewModel | `@MainActor final class … : ObservableObject` | Orchestration; publishes plain `Sendable` structs |
| Service | `actor` or `struct` in a package | I/O, one responsibility, protocol-fronted |
| Model | `@Model` in `Persistence`, structs in `Core` | Never crosses into a View |

Views receive row structs — `LocationRow`, `IssueSnapshot`, `SessionSnapshot` — never
`PersistentModel`.

### 4.4 Composition root

```swift
@MainActor
final class AppDependencies {
    let container: ModelContainer
    let uploadStore: UploadStore            // Persistence impl of UploadKit's protocol
    let uploadCoordinator: UploadCoordinator
    let captureService: CaptureServicing
    let planRenderer: PlanRendering
    let realtime: RealtimeChannel?          // nil when the flag is off
    let logger: Logging
    let clock: Clock
}
```

| Injected seam | Why it exists |
|---|---|
| `Clock` | Stale GPS, trusted time, and backoff test deterministically |
| `UploadStore` | Keeps `UploadKit` free of SwiftData |
| `UploadTransport` | `MockTransport` scripts 503/403/timeout per part |
| `CaptureSessionControlling` | State machine tests run on CI without a camera |
| `RandomNumberGenerator` | Jitter is assertable |

### 4.5 Startup sequence

Each step guarded and logged separately. Never one `try` around init.

| # | Step | On failure |
|---|---|---|
| 1 | Crash reporting | Continue — must never block launch |
| 2 | Logger + os.log categories | Continue with a no-op logger |
| 3 | Keychain: audit HMAC key, tokens | Block, show recovery screen |
| 4 | `ModelContainer` + migration | Block, offer diagnostic export |
| 5 | Recreate background session, reconcile tasks ↔ store | Continue, mark jobs `pending` |
| 6 | Audit chain verify (async) | Flag in Diagnostics |
| 7 | Sweep orphan files, temp parts, stale derived images | Log only |
| 8 | Face ID gate at `RootView` | Retry / passcode fallback |

## 5. Data flows

### 5.1 Capture → stored evidence

| # | Step | Thread | Failure |
|---|---|---|---|
| 1 | Shutter | `@MainActor` | — |
| 2 | Write file to `media/…` | `sessionQueue` / `writerQueue` | Abort, surface error |
| 3 | Apply `.completeUnlessOpen` | same | Abort |
| 4 | Stream SHA-256 in 1 MB chunks | `hashQueue` | Abort, delete file |
| 5 | Build `TrustedTimestamp` + GPS (nullable) | `hashQueue` | Degrade confidence, never abort |
| 6 | Insert `Capture` via `@ModelActor` | background | Retry once, then orphan-sweep at launch |
| 7 | Enqueue upload job with `priority` | `UploadCoordinator` | Stays `pending` |
| 8 | Thumbnail to UI | `@MainActor` | — |

**Invariant:** no DB row without a hash; no file without a row for longer than one launch cycle.

### 5.2 Upload

```
pending → planning → uploading ⇄ waitingForURL / waitingForNetwork → completing → synced
                          └────────────► failed (budget exhausted only)
```

| # | Step | Note |
|---|---|---|
| 1 | Single PUT (<5 MB) or 8 MB uniform parts | R2 requires equal non-final parts |
| 2 | `POST /uploads` with Firebase ID token | Backend verifies uid matches the key |
| 3 | Materialize ≤2 parts to temp files | Background session needs files on disk |
| 4 | `uploadTask(with:fromFile:)`, `taskDescription = "jobID#part"` | `taskIdentifier` is reused |
| 5 | 200 + ETag → delete temp part | Disk stays bounded |
| 6 | 403 → `waitingForURL` → refresh | No retry budget consumed |
| 7 | `POST /complete` → `remoteKey` + verification code | |
| 8 | Store update via `UploadStore` | The only path that mutates job state |

### 5.3 Cold launch reconciliation

| Source | Situation | Action |
|---|---|---|
| `session.allTasks` | Task alive + record | Reattach |
| `session.allTasks` | Task alive, no record | Cancel, log |
| `UploadStore` | `uploading`, no task | Reset to `pending`, re-enqueue |
| `Realtime` snapshot | Server completed, local unaware | Advance to `synced` after hash match |

Forward-only: nothing moves a job backwards from `synced`.

### 5.4 Report export

```
Session → SessionSnapshot (one fetch)
        → ReportLayoutEngine (pure, no UIKit) → [ReportPage]
        → PDFPageRenderer (UIKit, per-page autoreleasepool)
        → temp file → atomic move → share sheet
```

| Rule | Reason |
|---|---|
| Layout counts images, renderer draws them | Guarantees no dropped evidence |
| `CGImageSourceCreateThumbnailAtIndex` downsampling | 160 full-size images = jetsam |
| Renders the stamped/annotated derivative | The original stays clean and hashed |
| Temp file + `moveItem` | A kill mid-render never surfaces a partial file |

### 5.5 Metadata sync

| Direction | Trigger | Conflict rule |
|---|---|---|
| Pull `POST /sync/pull` | Foreground, network restore, `syncInterval` | Server rows win for anything the client has not touched |
| Push `POST /sync/push` | Same, plus a full queue batch | LWW on `clientUpdatedAt`, enforced in SQL |
| Both | — | `Session.state` monotonic; `captures` insert-only; deletes are tombstones |

Cursors are server-assigned `rev` counters, never timestamps ([08](08-auth-sync.md)). Media never
enters the sync protocol — bytes go to R2.

### 5.6 Concurrency map

| Context | Type | Holds |
|---|---|---|
| UI | `@MainActor` | ViewModels, `mainContext` |
| DB writes off-UI | `@ModelActor` | Its own `ModelContext` |
| Upload | `actor UploadCoordinator` | Job table, effect execution |
| Capture config | `sessionQueue` (serial) | `AVCaptureSession` |
| Sample buffers | `videoDataQueue` / `audioDataQueue` | Writer input |
| Hashing | `hashQueue` (`.utility`) | Streaming reads |
| BLE | `actor DeviceLinkManager` | `CBCentralManager` |
| WebSocket | `actor RealtimeChannel` | Task + ping timer |

| Rule | Rationale |
|---|---|
| Pass `PersistentIdentifier`, never `PersistentModel`, across actors | `ModelContext` is not `Sendable` |
| Never call `startRunning()` on main | Blocks 300–800 ms |
| No `@unchecked Sendable` to silence a warning | It hides the actual race |

## 6. Infrastructure

### 6.1 Filesystem

| Path | Protection | Backed up | Evidence |
|---|---|---|---|
| `<AppSupport>/media/<project>/<session>/<capture>.<ext>` | `.completeUnlessOpen` | No | **Yes** |
| `<AppSupport>/plans/<project>/<sheet>.<ext>` | `.completeUnlessOpen` | No | Yes |
| `<AppSupport>/derived/<…>-stamped.jpg` | `.completeUnlessOpen` | No | No — regenerable |
| `<Caches>/plans/<sheet>/tiles/` | default | No | No |
| `<Caches>/prebuffer/` | default | No | No |
| `<tmp>/upload-parts/` | `.completeUnlessOpen` | No | No |
| SwiftData store | `.complete` | No | Metadata |

The DB stores **relative paths**; absolute paths break on reinstall or restore.

### 6.2 Configuration

| Item | Where | Committed |
|---|---|---|
| `GoogleService-Info.plist` | `App/Config/` | No — CI writes from secret |
| Backend base URL, bucket, flags | `*.xcconfig` per environment | `.example` only |
| R2 access keys | Backend only | Never in the app |
| Feature flags (`realtimeEnabled`, `preRecordEnabled`) | `xcconfig` → `AppConfig` | Yes |

Schemes: `SiteLog-Debug`, `SiteLog-Staging`, `SiteLog-Release`.

### 6.3 CI

Green from week 1, runs per PR.

| Job | Gate |
|---|---|
| Build each package standalone | Zero warnings (`-warnings-as-errors`) |
| Unit tests per package | Scoped to the changed package + `Core` |
| `Core` purity check | No framework imports |
| Boundary check | Remove `Realtime` → app still builds |
| `grep -rn "print(" Sources/` | Must be empty |
| Secret scan | No env/plist values in the diff |
| SwiftLint / SwiftFormat | Clean |
| Backend: `vitest`, `tsc --noEmit`, ESLint, migrations against a fresh DB | Clean; key-prefix and idempotency tests must pass |

## 7. Schedule

| Week | Work |
|---|---|
| 1–2 | SPM scaffold, **green CI from day one**, SwiftData model, project/session/location screens, basic camera |
| 3–4 | Upload engine: background session, chunking, resume, retry, state machine |
| 5–6 | Hash + trusted time, annotation layer, PDF/CSV export with branding, Face ID + Data Protection |
| 7–8 | Floor plan pins, checklist templates, BLE, diagnostics, test expansion |
| — | Backend ([14](14-backend.md)) is built alongside week 3–4; the WebSocket half lands with week 9 |
| 9–10 | Sync engine: pull/push, tombstones, mutation queue, full resync |
| 11–12 | WebSocket channel, pre-record buffer, polish, TestFlight feedback |

TestFlight from end of week 4.

| Tier | Items | Reason |
|---|---|---|
| Never cut | Upload engine, hash + trusted time, PDF export, backend endpoints 1–4 | The product's entire claim |
| High | Annotation, branding, assignee, CSV | Cheap; absence reads as unfinished |
| Medium | Floor plan pins, checklist templates | Table stakes, ~1 week each |
| Cut first | Pre-record buffer, audio, real BLE hardware (keep the mock), WebSocket | Impressive, not load-bearing |

**Escape hatch:** single-device use needs no sync at all. If week 9 arrives and the upload engine is
not solid, ship single-device and add sync after TestFlight — the schema and endpoints already
support it.

Why 12 weeks and not 8:

- Features 11–13 (plan pins, annotation, checklists) added two weeks — they are category table stakes.
- Dropping Firestore added two more: offline persistence, delete propagation, and listener fan-out
  were all things the SDK did for free.

## 8. Conventions

| Rule | Detail |
|---|---|
| Group by feature | Dependencies point inward; `Core` imports no frameworks |
| Constants in dedicated `enum`s | No raw literals at call sites; spacing/color/type via `DesignSystem` |
| Log every action with data | `"Upload failed — {captureId, part: 3/12, bytes: 4.1MB, status: 503}"`, successes included |
| Log the error object | `String(reflecting:)`, never a hand-written message. Catch broad, not narrow. **No `print`** |
| Guard startup steps individually | Never one `try` around init; crash reporting first |
| Extract at ~80 lines | Variants are parameters, not branching functions |
| No business logic in views | Views lay out, view models orchestrate |
| Explicit types, `let` by default | |

### 8.1 Naming

| Kind | Pattern | Example |
|---|---|---|
| Package | Noun, no prefix | `UploadKit`, `Plans` |
| ViewModel | `<Screen>ViewModel` | `SurveySessionViewModel` |
| Service protocol | `<Noun>ing` / `<Noun>Providing` | `PlanRendering` |
| Actor | `<Noun>Coordinator` / `<Noun>Manager` | `UploadCoordinator` |
| Constants | `enum <Domain>Constants` | `UploadConstants` |
| Row/snapshot struct | `<Entity>Row` / `<Entity>Snapshot` | `LocationRow` |
| Test file | `<Type>Tests.swift` | `UploadStateMachineTests.swift` |

### 8.2 Definition of done (every change)

- Clean build, zero warnings, each package independently.
- Scoped tests for what changed, not the full suite.
- Diff review: literals, hardcoded user-facing strings, unlogged `catch`, cross-boundary imports,
  constants bolted onto models.
- No env or secret value in the diff or in logs.

### 8.3 Adding a feature — checklist

1. Does it belong in an existing package? A new package needs a dependency reason, not a size reason.
2. Business rules go in `Core`, testable without a device.
3. Constants get their own `enum` before the first literal is written.
4. Views get a row struct; no `PersistentModel` crosses the boundary.
5. Every action and every `catch` logs with structured data.
6. Schema change → new `SchemaV{n}` + migration test against an old-version fixture.
7. Scoped tests for the change only.
8. Diff review as in H.2.

## 9. Feature specs

| # | Document |
|---|---|
| 01 | [Projects, sessions, locations](01-project-session.md) |
| 02 | [Capture pipeline](02-capture.md) |
| 03 | [Issue tracking & before/after pairing](03-issue-tracking.md) |
| 04 | [Upload engine](04-upload-engine.md) |
| 05 | [PDF & spreadsheet export](05-reporting.md) |
| 06 | [DeviceLink: BLE measuring tools](06-device-link.md) |
| 07 | [Security & audit log](07-security.md) |
| 08 | [Auth & sync](08-auth-sync.md) |
| 09 | [Diagnostics & observability](09-diagnostics.md) |
| 10 | [Realtime progress channel](10-realtime-progress.md) |
| 11 | [Floor plans & issue pins](11-floorplan-pins.md) |
| 12 | [Annotation & verifiable stamps](12-annotation.md) |
| 13 | [Checklist templates](13-checklists.md) |
| 14 | [Backend](14-backend.md) |
