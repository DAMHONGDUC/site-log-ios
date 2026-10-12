# Field work

<dl><dd>

- What the supervisor does on site: organize the walk, capture, log and verify issues, pin them on
  plans, mark up photos, run checklists, read measuring tools.
- Architecture and data model: [00-overview.md](00-overview.md).

</dd></dl>

## Contents

<dl><dd>

| Spec | Topic |
|---|---|
| [01](#01-projects-sessions-locations) | Projects, sessions, locations |
| [02](#02-capture-pipeline) | Capture pipeline — session, metadata and hashing, pre-record buffer |
| [03](#03-issues-and-before-after-pairing) | Issues and before-after pairing |
| [06](#06-devicelink-ble-measuring-tools) | DeviceLink BLE measuring tools |
| [11](#11-floor-plans-and-issue-pins) | Floor plans and issue pins |
| [12](#12-annotation-and-verifiable-stamps) | Annotation, stamps, dictation, trusted time, verification code |
| [13](#13-checklist-templates) | Checklist templates |

---

</dd></dl>

## 01. Projects, sessions, locations

<dl><dd>

- Modules: `SiteLog/Presentation/Projects`, `DomainLayer`, `DataLayer`, `Packages/DataLayer/Sources/DataLayer/DataSources/Local/Persistence`

**Goal:** build the `Project → Session → Location` tree faster than paper, fully offline,
one-handed.

| In | Out |
|---|---|
| CRUD for all three; 3-level tree (`floor → unit → room`) | Multi-user sharing (v2) |
| Bulk generation from a template; cloning a tree from another project | Excel/CAD import |
| Closing and reopening sessions | |

```
Project list → [+] New project → Project detail: [Sessions] [Locations] [Plans]
  → [+] Start session → Survey screen: locations + capture/issue badges
      → Select location → Capture (02) / Checklist (13) / Plan (11)
  → [End session] → state = closed
```

- Camera entry point in the lower half; badges read from the local store and never wait on upload.
- Bulk generation (`Floors 1...20 × 4 units, "{floor}-{unit:02}"` → 80 locations) runs in one
  transaction, previews first 5 / last 3 / total, rejects duplicates by name, caps at
  `maxGeneratedPerBatch`.
- Badge counts come from one batched repository call per screen, never per row.

```swift
struct LocationRow: Identifiable, Sendable {
    let id: PersistentIdentifier
    let code: String
    let captureCount: Int
    let openIssueCount: Int
    let pendingUploadCount: Int
}

enum LocationTemplateLimits {
    static let maxGeneratedPerBatch: Int = 2000
    static let maxDepth: Int = 3
    static let previewHeadCount: Int = 5
    static let previewTailCount: Int = 3
}
```

| Risk | Handling |
|---|---|
| Closing a session by accident | Reopen button; state shown in the header |
| Project delete removes GB of media | Confirmation states numbers: "3 sessions, 412 photos, 2.1 GB, 87 not uploaded" |
| Delete while files are `pending` | Blocked outright |

**Done**

- Project → session → 80 locations → capture in airplane mode
- 500-row list at 60 fps
- Kill mid-generation leaves no partial records

**Tests**

- Template edge cases (1 floor, 1 unit, collisions)
- Batch cap
- Depth-4 rejected
- `closed` rejects `addCapture`
- Cascade delete leaves no orphans
- Migration from a 100-location `SchemaV1` fixture

---

</dd></dl>

## 02. Capture pipeline

<dl><dd>

- Module: `Packages/DataLayer/Sources/DataLayer/DataSources/Local/Capture`

**Goal:** one `AVCaptureSession` for photo, video and audio without teardown; every file hashed
before it reaches the DB.

| In | Out |
|---|---|
| Photo, video + audio, standalone audio; torch, zoom, flip, timer | Photo editing |
| Continuous capture with a thumbnail strip | Photo library import |
| GPS, `deviceModel`, `capturedAt`, `trustedTime`; SHA-256 on close | |
| 30-second pre-record buffer | |

### 02.1 Session and state

<dl><dd>

```
AVCaptureSession
├── inputs:  video (back/front), audio (mic)
├── outputs: AVCapturePhotoOutput → photos
│            AVCaptureVideoDataOutput / AudioDataOutput → AVAssetWriter
└── preview: AVCaptureVideoPreviewLayer (UIViewRepresentable)

idle → configuring → ready → capturingPhoto → ready
                       ↓                        ↑
                   recording → finalizing (finishWriting + hash)
```

- `AVAssetWriter` over `AVCaptureMovieFileOutput`: needed for the pre-record buffer and bitrate
  control over 3G.
- `startRunning`/config on `sessionQueue`; buffers on `videoDataQueue`/`audioDataQueue`; hashing on
  `hashQueue`; UI on `@MainActor`. Never `startRunning()` on main (300–800 ms block).
- `interrupted` (call, backgrounding) while recording **finalizes rather than discards**.

</dd></dl>

### 02.2 Metadata and hashing

<dl><dd>

| Field | Source | When unavailable |
|---|---|---|
| `capturedAt` | `Date()` at `didFinishProcessingPhoto` | Always present |
| `trustedTime` | Clock + uptime + cached server offset ([12.4](#124-trusted-time)) | Degrades to `.deviceOnly` |
| GPS + accuracy | `CLLocationManager`, `.nearestTenMeters` | `nil`; a fix older than `locationStaleAfter` is `nil`, never wrong |
| `sha256` | Streamed from the closed file | Always present |

```swift
func sha256(ofFileAt url: URL) throws -> String {
    let handle = try FileHandle(forReadingFrom: url)
    defer { try? handle.close() }
    var hasher = SHA256()
    while let chunk = try handle.read(upToCount: HashConstants.streamingChunkBytes), !chunk.isEmpty {
        hasher.update(data: chunk)
    }
    return hasher.finalize().map { String(format: "%02x", $0) }.joined()
}
```

- Stream in chunks: `Data(contentsOf:)` on a 1.5 GB video triggers jetsam.
- Files: `media/<project>/<session>/<capture>.<ext>`, `.completeUnlessOpen`, excluded from backup.

</dd></dl>

### 02.3 Pre-record buffer

<dl><dd>

- Keeps the last 30 s when record is pressed.
- Never raw buffers in RAM: `AVAssetWriter` writes 3-second segments to `<Caches>/prebuffer/` in a
  ring of `segmentCount`; on record, join with `AVMutableComposition`.
- Off by default; disables below `minBatteryLevel`.

```swift
enum CaptureConstants {
    static let videoBitrate: Int = 8_000_000
    static let maxVideoDuration: TimeInterval = 600
    static let locationStaleAfter: TimeInterval = 120
    static let minFreeDiskBytesForVideo: Int64 = 500 * 1024 * 1024
}
enum PreRecordConstants {
    static let segmentDuration: TimeInterval = 3
    static let segmentCount: Int = 11
    static let minBatteryLevel: Float = 0.20
}
enum HashConstants { static let streamingChunkBytes: Int = 1_048_576 }
```

| Risk | Handling |
|---|---|
| Disk fills mid-recording | Check free space first; below threshold, block video and state the remainder |
| Thermal throttling | `.serious` → lower bitrate; `.critical` → stop deliberately |
| Permissions | Camera, mic, location handled separately, never one combined alert |
| Rotation | Preview and writer transforms must match, or video is rotated in the PDF |

**Done**

- 50 photos with flat memory
- 3-minute 1080p plays back and hash reproduces
- Call mid-recording finalizes to `.pending`
- Airplane mode + denied location still captures

**Tests**

- Hash against known vectors and `shasum` on 200 MB
- State machine rejects recording during photo
- Interruption finalizes once
- Stale GPS → `nil`
- Ring buffer eviction. All run without a camera via `CaptureSessionControlling`

---

</dd></dl>

</dd></dl>

## 03. Issues and before-after pairing

<dl><dd>

- Modules: `SiteLog/Presentation/Issues`, `DomainLayer`, `DataLayer`

- Core business feature: prove "broken last week, fixed now" with two photos of the same spot.

**Goal:** log an issue in under 20 s, one-handed; in a later session reopen it at the same location,
shoot verification, render the pair in the PDF.

| In | Out |
|---|---|
| Issue CRUD, multiple captures, severity, status, due date | Account-linked assignment (subcontractors have no app) |
| Assignee and trade (free text, autocompleted) | Multi-user comment threads (v2) |
| Carry-over of open issues; pairing and closure by verification photo | |
| Phrase library, on-device dictation, voice notes | |

### 03.1 Flows

<dl><dd>

```
Log:     Capture → shoot → [Attach issue] → sheet (description, severity=Major,
         assignee, due, 🎤 dictate · 🔊 voice note · 📍 pin) → Save → back to camera
Verify:  New session → location → banner "3 open issues from 12 Aug" → issue
         → [Shoot verification] with prior photo at 30% overlay → [Resolved] [Still open] [Worse]
Close:   new Issue (status .verified, verification photo); old.resolvedByIssue = new,
         old.status = .resolved; original captures never touched
```

| Decision | Reason |
|---|---|
| Sheet returns to the camera | The user is walking a room; each camera restart costs ~1 s |
| Default severity `.major` | Defaulting to minor makes everything minor |
| `assigneeName` is free text | A name that groups the PDF is what gets used on site |
| 30% overlay | Without it the angles differ and the pair is worthless |

- Phrase library: ~30 seeded phrases; new typed phrases added; sorted by usage; synced via the
  backend's `phrases` table.

</dd></dl>

### 03.2 Design

<dl><dd>

```swift
struct IssuePairing: Sendable, Equatable {
    let previous: IssueSnapshot
    let current: IssueSnapshot?
    let outcome: PairingOutcome   // .resolved / .stillOpen / .worsened
}

enum IssueDefaults {
    static let severity: IssueSeverity = .major
    static let dueDateOffsetDays: Int = 7
    static let maxCapturesPerIssue: Int = 20
    static let overlayOpacity: Double = 0.30
    static let staleIssueSessionThreshold: Int = 3
}
```

- `PairIssuesUseCase` lives in `DomainLayer`, imports no frameworks — the most error-prone logic in the app.
- Upload priority: critical 100 · major 50 · minor 10 · no issue 5 · video −20 (video blocks dozens
  of photos behind it).

| Risk | Handling |
|---|---|
| Location deleted or renamed between sessions | Delete blocked while open issues exist; rename keeps `id` + audit entry |
| Verification at the wrong spot | Overlay; the PDF prints `Location.code` under every image |
| Issues piling up | Past `staleIssueSessionThreshold` the banner changes color and the PDF gets a section |

**Done**

- One issue with photo in under 20 s, measured
- Session 2 surfaces exactly the 3 open issues offline
- Closing leaves the original byte-identical

**Tests**

- Pairing with 0/1/n open issues
- Skips `.verified`
- Closing never mutates prior captures
- Priority across severity × kind
- Delete-with-open-issues rejected
- Phrase ordering tie-break

---

</dd></dl>

</dd></dl>

## 06. DeviceLink BLE measuring tools

<dl><dd>

- Module: `Packages/DataLayer/Sources/DataLayer/DataSources/Local/DeviceLink` · mock: `Tools/MockPeripheral/`

**Goal:** scan → connect → read a laser distance or moisture meter (Bosch GLM, Leica Disto) → attach
the reading to a `Capture`.

- BLE for control and small values; files never go over BLE.

```swift
public protocol DeviceProfile: Sendable {
    static var serviceUUID: CBUUID { get }
    static var notifyCharacteristicUUID: CBUUID { get }
    static func parse(_ data: Data) throws -> DeviceReading   // pure, tested on captured bytes
}

public struct DeviceReading: Sendable, Codable, Equatable {
    public let value: Double
    public let unit: MeasurementUnit      // .meter / .millimeter / .percentMoisture
    public let kind: MeasurementKind      // .distance / .area / .moisture
    public let measuredAt: Date
    public let deviceName: String
}
```

- One file per vendor profile. Named `DeviceReading` because `Foundation.Measurement` collides.
- `poweredOff → poweredOn → scanning → connecting → discovering → ready`; `disconnected` is normal
  (meters sleep). `DeviceLinkManager` is an `actor`.
- CoreBluetooth rules: keep a strong `CBPeripheral` reference, no commands before `.poweredOn`,
  check errors on both discover callbacks, reconnect via `retrievePeripherals(withIdentifiers:)`.
- UX: reading overlays the preview; status is a colored dot, no alerts; **never blocks capture**.
  Readings older than `measurementStaleAfter` are not attached.
- The macOS mock scripts invalid values, disconnects and garbage bytes, and makes CI possible.

```swift
enum DeviceLinkConstants {
    static let scanTimeout: TimeInterval = 15
    static let connectTimeout: TimeInterval = 10
    static let reconnectBaseDelay: TimeInterval = 2
    static let reconnectMaxDelay: TimeInterval = 60
    static let minimumRSSI: Int = -85
    static let measurementStaleAfter: TimeInterval = 30
    static let backgroundDisconnectDelay: TimeInterval = 300
}
```

**Risks**

- No hardware for byte formats → start on the mock and ship a raw-bytes "generic" profile
- Permission denied → feature hides itself
- Battery → no background scanning

**Done**

- Reads from the mock into a capture
- Killing the mock greys the dot, capture still works
- Relaunch reconnects within 10 s

**Tests**

- Vendor `parse` on real bytes
- Truncated/bad-checksum payloads throw
- Unit conversion
- Stale reading not attached
- Reconnect backoff capped
- Full flow against the mock

---

</dd></dl>

## 11. Floor plans and issue pins

<dl><dd>

- Modules: `Packages/DataLayer/Sources/DataLayer/DataSources/Local/Plans`, `SiteLog/Presentation/Plans`

**Goal:** import a floor plan, pin issues at exact coordinates, print a pin map per sheet.

- Out: DWG/CAD, measuring, plan editing.

```swift
@Model final class PlanSheet {
    var id: UUID; var project: Project; var name: String
    var sourceFileURL: URL        // relative
    var pageIndex: Int; var pixelSize: CGSize
    var sha256: String            // plans are evidence too
    var location: Location?
}

@Model final class PlanPin {
    var id: UUID; var sheet: PlanSheet; var issue: Issue
    var normalizedPoint: NormalizedPoint  // Domain type, 0…1 on both axes
    var createdAt: Date
}
```

- **Coordinates are 0…1, never pixels**, so pins survive re-rendering at any scale. `CGPoint` only
  inside `Plans`.
- One pin per issue; every move writes an audit entry.
- Rendering: `CATiledLayer` tiles on demand (A0 at 300 dpi never becomes one bitmap), PDFKit or
  `CGImageSource` as source, tile cache in `<Caches>/plans/`, pins in an overlay view.
- Interaction: **long-press drops a pin** (tap is for panning), tap opens the issue, drag confirms on
  release. Pins colored by severity, hollow when resolved, clustered below `clusterZoomThreshold`.
- Import: Files or share sheet; multi-page PDFs choose pages (one `PlanSheet` each); hashed; uploaded
  at low priority; capped at `maxPlanFileBytes`.

```swift
enum PlanConstants {
    static let maxPlanFileBytes: Int64 = 100 * 1024 * 1024
    static let maxZoomScale: CGFloat = 8
    static let clusterZoomThreshold: CGFloat = 2
    static let clusterRadiusPoints: CGFloat = 24
    static let pinDropLongPressDuration: TimeInterval = 0.4
    static let tileSize: CGSize = CGSize(width: 512, height: 512)
    static let uploadPriority: Int = 1
}
```

| Risk | Handling |
|---|---|
| Revised drawing | New `PlanSheet`, offer to migrate pins by normalized coordinate, keep the old sheet |
| Encrypted or corrupt PDF | Rejected at import with the reason |
| Pin on the wrong sheet | Sheet name at the viewer top and under every pin map |

**Done**

- 20-page A1 PDF, 50 pins, 60 fps pan/zoom
- A0 peak memory under 150 MB
- Pins land on the same spot after relaunch at a different zoom
- Fully offline

**Tests**

- `planPoint` round-trip through zoom/pan
- Same point at two scales
- Clustering
- Oversized and encrypted imports rejected
- Pin migration
- Sheet delete blocked while pins exist
- A0 memory

---

</dd></dl>

## 12. Annotation and verifiable stamps

<dl><dd>

- Modules: `Packages/DataLayer/Sources/DataLayer/DataSources/Local/Capture` (rendering), `DomainLayer` (models)

**Rule:** the original file is never touched; markup is a separate layer; stamps are a derived copy.

### 12.1 Annotation layer

<dl><dd>

```swift
struct NormalizedPoint: Codable, Sendable, Equatable { var x: Double; var y: Double }
struct NormalizedRect:  Codable, Sendable, Equatable { var origin: NormalizedPoint; var width: Double; var height: Double }

enum AnnotationShape: Codable, Sendable, Equatable {
    case arrow(from: NormalizedPoint, to: NormalizedPoint, style: AnnotationStyle)
    case rect(NormalizedRect, style: AnnotationStyle)
    case ellipse(NormalizedRect, style: AnnotationStyle)
    case freehand(points: [NormalizedPoint], style: AnnotationStyle)
    case text(String, at: NormalizedPoint, style: AnnotationTextStyle)
}
```

- `Annotation { id, capture, shapes: [AnnotationShape] (JSON), createdAt, updatedAt }`, 1:1 with a
  capture. Normalized so phone markup renders correctly on A4. `Normalized*` exist because `DomainLayer`
  may not import CoreGraphics; `AnnotationStyle` avoids clashing with `SwiftUI.ShapeStyle`.
- Keeps the hash valid, stays editable, prints annotated or clean, syncs as a few KB.
- Editor: Arrow (default), Box, Circle, Pen, Text; stroke scales with image size; undo capped at
  `maxUndoSteps`; commits on exit. Edits write an audit entry.

</dd></dl>

### 12.2 Stamped derivatives

<dl><dd>

- File: `derived/<…>/<captureID>-stamped.jpg`.
- Carries date/time, coordinates and accuracy, project, location code, logo.
- Generated on demand, cached; never hashed, never evidence, excluded from integrity checks.

</dd></dl>

### 12.3 Dictation and voice notes

<dl><dd>

- `SFSpeechRecognizer`, `requiresOnDeviceRecognition = true`: site audio never leaves the device.
- Vietnamese and English; falls back to the phrase library.
- A voice note is an ordinary audio `Capture`; dictated text lands in `Issue.detail`.

</dd></dl>

### 12.4 Trusted time

<dl><dd>

```swift
struct TrustedTimestamp: Codable, Sendable {
    let deviceTime: Date
    let uptimeNanos: UInt64         // detects clock jumps within a launch
    let serverOffset: TimeInterval? // serverTime − deviceTime
    let offsetMeasuredAt: Date?
    let confidence: TimeConfidence
}
```

| Confidence | Condition |
|---|---|
| `.serverVerified` | Offset measured within `serverOffsetValidity`, under `maxAcceptableOffset` |
| `.sessionConsistent` | No server contact, uptime matches wall-clock progression |
| `.deviceOnly` | Clock jumped, or relaunched with no server contact |

- Offset comes from the `Date` header of any backend response.
- Confidence is **printed in the report**; a capture is never rejected for low confidence.

</dd></dl>

### 12.5 Verification code

<dl><dd>

- On upload completion the backend records the hash and returns a short code.
- Printed under each image; resolvable at `GET /verify/:code` ([03-backend.md](03-backend.md#3-endpoints)).

| State | Meaning | Report wording |
|---|---|---|
| `registered` | Server recorded a client-supplied hash at a known time | "registered {code}" |
| `verified` | Server re-read the object and recomputed the hash | "verified {code}" |
| unsynced | Nothing left the device | "not yet verified" |

- Never print a code the server does not hold, or "verified" for a registered capture.

```swift
enum AnnotationConstants {
    static let maxUndoSteps: Int = 20
    static let strokeWidthRatio: CGFloat = 0.004   // × image width
    static let derivedImageMaxPixelSize: CGFloat = 2000
}
enum TrustedTimeConstants {
    static let serverOffsetValidity: TimeInterval = 3600
    static let maxAcceptableOffset: TimeInterval = 120
}
```

**Done**

- 5 shapes survive relaunch over an original whose hash still verifies
- Phone markup is proportional on A4
- Deleting the derived cache loses nothing
- Moving the clock a day ahead drops confidence to `.deviceOnly` and the report says so
- Dictation works in airplane mode

**Tests**

- `AnnotationShape` Codable round-trip
- Same render at two sizes
- Original never mutated
- Undo bounds
- Confidence for fresh/stale offset, clock jump, relaunch
- Oversized offset rejected
- "not yet verified" wording
- Stamp position correct in three orientations

---

</dd></dl>

</dd></dl>

## 13. Checklist templates

<dl><dd>

- Modules: `SiteLog/Presentation/Checklists`, `DomainLayer`, `DataLayer`

**Goal:** walk a location against a template, tick items, turn a failed item into an issue without
retyping.

- Out: weighted scoring, branching, regulatory libraries.

```swift
@Model final class ChecklistTemplate { var id: UUID; var name: String; var appliesTo: LocationKind?
    var items: [ChecklistTemplateItem]; var isBuiltIn: Bool; var usageCount: Int }
@Model final class ChecklistTemplateItem { var id: UUID; var order: Int; var text: String
    var defaultSeverity: IssueSeverity; var requiresPhotoOnFail: Bool }
@Model final class ChecklistRun { var id: UUID; var template: ChecklistTemplate; var session: Session
    var location: Location; var startedAt: Date; var completedAt: Date?; var results: [ChecklistResult] }
@Model final class ChecklistResult { var id: UUID; var templateItem: ChecklistTemplateItem
    var outcome: ChecklistOutcome   // .pass / .fail / .notApplicable / .unanswered
    var note: String; var issue: Issue?; var answeredAt: Date? }
```

- A run stores its own results; editing a template never rewrites completed runs.
- Flow: pick a template (recent first) → one row per item `[✓ Pass] [✕ Fail] [– N/A]` → fail opens
  the camera if required and prefills the issue sheet ([03](#03-issues-and-before-after-pairing)) →
  header progress "14/22"; finish at 100% answered. One tap per item in the common case; runs are
  resumable.
- Built-ins (handover: living room, bedroom, bathroom, kitchen, balcony; electrical; plumbing;
  structural) are editable and duplicable, not deletable; edits fork a copy. Templates export/import
  as JSON.
- The PDF gets a per-location table (item, outcome, note, issue) — it shows what **passed** too.

```swift
enum ChecklistConstants {
    static let maxItemsPerTemplate: Int = 200
    static let recentTemplateCount: Int = 5
    static let templateExportVersion: Int = 1
}
```

**Risks**

- Tick-through without inspecting is visible from per-answer timestamps
- Imported JSON is validated (version, item cap) and treated as data

**Done**

- 22-item run offline, two fails → two prefilled issues
- Kill mid-run resumes
- Template edit leaves the completed run and its PDF section unchanged

**Tests**

- Fail creates one issue with item text and severity
- Fail → pass resolves it
- Template edit does not alter runs
- Completion percentage
- JSON import validation
- Built-ins fork on edit

</dd></dl>
