# 01 — Projects, sessions, locations

Modules: `App/Features/Projects`, `Core`, `Persistence`

## Goal

Build the `Project → Session → Location` tree faster than paper, fully offline, navigable
one-handed.

## Scope

| In | Out |
|---|---|
| CRUD for all three entities | Multi-user sharing (v2, [08](08-auth-sync.md)) |
| 3-level location tree (`floor → unit → room`) | Excel/CAD import |
| Bulk location generation from a template | |
| Cloning a location tree from another project | |
| Closing and reopening sessions | |

## Flow

```
Project list
  → [+] New project (name, address, client)
  → Project detail: [Sessions] [Locations] [Plans]
      → [+] Start session (surveyor, notes)
      → Survey screen: location list + capture/issue badges
          → Select location → Capture (02) / Checklist (13) / Plan (11)
      → [End session] → state = closed
```

Survey screen rules:

- Camera entry point in the lower half — thumb reach.
- Badges read from the local store and update instantly, independent of upload.
- No blocking spinner; nothing here touches the network.

## Bulk generation

```
Floors 1...20   Units/floor 4   Template "{floor}-{unit:02}"
→ 1-01 … 20-04   (80 locations)
```

- Single transaction, never row by row.
- Preview before commit: first 5 codes, last 3, total.
- Duplicate codes rejected, naming the exact collisions.
- Hard cap `maxGeneratedPerBatch`.

## Technical design

```swift
@MainActor
final class SurveySessionViewModel: ObservableObject {
    @Published private(set) var locations: [LocationRow]
    @Published private(set) var state: SessionState

    func startSession(surveyor: String, note: String) async throws
    func closeSession() async throws
    func generateLocations(_ spec: LocationTemplateSpec) async throws -> LocationTemplatePreview
    func commitLocations(_ preview: LocationTemplatePreview) async throws
}

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

- Views never hold `PersistentModel`.
- Badges use `fetchCount` batched once per screen; per-row queries across 80 locations stutter on
  scroll.

## Known risks

| Risk | Handling |
|---|---|
| Accidentally closing a session | Reopen button; state in the header, not in a menu |
| Project delete removes GB of media | Confirmation states numbers: "3 sessions, 412 photos, 2.1 GB, 87 not uploaded" |
| Delete while files are `pending` | Blocked outright, not warned |

## Definition of done

- Project → session → 80 locations → open capture, in airplane mode, no errors.
- 500-location list scrolls at 60fps on device.
- Kill mid bulk-generation → no partial records on relaunch.
- Zero warnings.

## Tests

| Test | Kind |
|---|---|
| Template generates correct codes for edge cases (1 floor, 1 unit, collisions) | unit, `Core` |
| Rejects batches over `maxGeneratedPerBatch` | unit |
| Rejects depth-4 locations | unit |
| `closed` session rejects `addCapture` | unit |
| Cascade delete removes files, leaves no orphans | integration |
| Migration from a `SchemaV1` fixture with 100 locations | integration |
