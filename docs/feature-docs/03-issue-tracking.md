# 03 — Issue tracking & before/after pairing

Modules: `App/Features/Issues`, `Core`

The core business feature. Any app takes photos; what supervisors pay for is proving "this was
broken last week, it is fixed now" with two photos of the same spot.

## 1. Goal

- Log an issue in under 20 seconds, standing, one-handed.
- In a later session, reopen the exact prior issue at the exact location and shoot verification.
- Render the pair side by side in the PDF ([05](05-reporting.md)).

## 2. Scope

| In | Out |
|---|---|
| Issue CRUD, multiple captures per issue | Push notifications |
| Severity, status, due date | Account-linked assignment — the subcontractor has no app |
| Assignee and trade (free text) | Multi-user comment threads (v2) |
| Carry-over of open issues per location | |
| Pairing and closure by verification photo | |
| Phrase library + on-device dictation + voice notes | |

## 3. Flows

### 3.1 Log an issue

```
Capture screen → shoot → thumbnail
  → [Attach issue] → sheet:
      • Description (typed, dictated, or from the phrase library)
      • Severity: [Critical] [Major] [Minor]   ← default Major
      • Assignee / trade (autocomplete from prior entries)
      • Due date (optional)
      • [🎤] dictate · [🔊] voice note · [📍] pin on plan
  → Save → back to camera
```

| Decision | Reason |
|---|---|
| Sheet returns to the camera, not a list | The user is walking a room; each camera restart costs ~1 s |
| Default severity `.major` | Defaulting to minor makes everything minor — nobody changes defaults |
| `assigneeName` is free text | Competitors assign to accounts; on site the subcontractor has none. A name that groups the PDF is the part that gets used |

Dictation and voice notes: [12](12-annotation.md) §6. Plan pinning: [11](11-floorplan-pins.md).

### 3.2 Before/after pairing

```
New session → select location
  → Banner: "3 open issues from 12 Aug"
  → Select issue → [Shoot verification]
      → Prior photo overlaid at 30% on the live preview
  → Shoot → outcome: [Resolved] [Still open] [Worse]
```

- The overlay is what makes the pair meaningful; without it the angles differ and the comparison is
  worthless.
- `Issue` anchors to `Location`, so history surfaces across sessions — this is why `Location`
  belongs to `Project` ([00](00-project-info.md) §3).

### 3.3 Closing an issue

1. Create a new `Issue` in the current session, `status = .verified`, carrying the verification photo.
2. Set `oldIssue.resolvedByIssue = newIssue`, `oldIssue.status = .resolved`.
3. Never modify or delete the original captures. The history is the product.

## 4. Phrase library

- Seed ~30 construction/handover phrases; new typed phrases are added automatically.
- Sorted by usage count, most recent first on ties.
- Local, synced through the backend's `phrases` table ([08](08-auth-sync.md)).

## 5. Technical design

```swift
@MainActor
final class IssueEditorViewModel: ObservableObject {
    @Published var title: String
    @Published var severity: IssueSeverity
    @Published var assigneeName: String?
    @Published var dueDate: Date?
    @Published private(set) var suggestions: [PhraseSuggestion]

    func attach(captureIDs: [PersistentIdentifier]) async throws
    func save() async throws -> PersistentIdentifier
}

struct IssuePairing: Sendable, Equatable {
    let previous: IssueSnapshot
    let current: IssueSnapshot?
    let outcome: PairingOutcome   // .resolved / .stillOpen / .worsened
}

enum IssueDefaults {
    static let severity: IssueSeverity = .major
    static let dueDateOffsetDays: Int = 7
    static let maxCapturesPerIssue: Int = 20
    static let phraseSuggestionCount: Int = 6
    static let assigneeSuggestionCount: Int = 5
    static let overlayOpacity: Double = 0.30
    static let staleIssueSessionThreshold: Int = 3
}
```

`IssuePairingService` lives in `Core`, imports no frameworks, takes snapshots and returns pairings.
It is the most error-prone logic in the app.

## 6. Upload priority

| Input | Priority |
|---|---|
| `.critical` | 100 |
| `.major` | 50 |
| `.minor` | 10 |
| Capture with no issue | 5 |
| Video (any severity) | −20 |

Video is penalized because it occupies bandwidth long enough to block dozens of photos behind it.

## 7. Known risks

| Risk | Handling |
|---|---|
| Location deleted or renamed between sessions | Deletion blocked while open issues exist; rename keeps `id` + audit entry |
| Verification shot at the wrong spot | Overlay reduces it; the PDF prints `Location.code` under every image |
| Issues accumulating across sessions | Past `staleIssueSessionThreshold` the banner changes color and the PDF gets a dedicated section |

## 8. Definition of done

- Logging one issue with a photo takes under 20 seconds, measured.
- Session 2 surfaces exactly the 3 open issues from session 1, offline.
- Closing leaves the original `Capture` byte-identical; hash still verifies.
- Zero warnings.

## 9. Tests

| Test | Kind |
|---|---|
| Pairing with 0 / 1 / n open issues per location | unit, `Core` |
| Pairing skips issues already `.verified` | unit |
| Closing does not mutate prior captures (full snapshot comparison) | unit |
| `priority` across 5 severity × kind combinations | unit |
| Deleting a location with open issues is rejected | unit |
| Phrase and assignee ordering by usage with a stable tie-break | unit |
