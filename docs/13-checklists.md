# 13 — Checklist templates

Modules: `App/Features/Checklists`, `Core`

Vietnamese handover guidance is published as room-by-room checklists of 5–12 steps, and
checklist-driven inspection is a whole competitor category
([00-project-info.md](00-project-info.md) §Market). Free-form capture alone leaves the inspector
remembering what to check.

## Goal

Walk a location against a template, tick items, and turn any failed item into an issue without
re-typing it.

## Scope

| In | Out |
|---|---|
| Template CRUD, instantiation per `Location` | Weighted scoring and pass thresholds |
| Pass / fail / N-A with notes and photos | Conditional branching between items |
| Automatic issue creation on fail | Regulatory template libraries |
| Per-session and per-location progress | |
| Seeded handover and structural templates | |
| Template export/import as JSON | |

## Model

```swift
@Model final class ChecklistTemplate {
    var id: UUID
    var name: String                    // "Apartment handover — bedroom"
    var appliesTo: LocationKind?        // nil = any
    var items: [ChecklistTemplateItem]  // ordered
    var isBuiltIn: Bool
    var usageCount: Int
}

@Model final class ChecklistTemplateItem {
    var id: UUID
    var order: Int
    var text: String                    // "Window closes and locks fully"
    var defaultSeverity: IssueSeverity
    var requiresPhotoOnFail: Bool
}

@Model final class ChecklistRun {
    var id: UUID
    var template: ChecklistTemplate
    var session: Session
    var location: Location
    var startedAt: Date
    var completedAt: Date?
    var results: [ChecklistResult]
}

@Model final class ChecklistResult {
    var id: UUID
    var templateItem: ChecklistTemplateItem
    var outcome: ChecklistOutcome       // .pass / .fail / .notApplicable / .unanswered
    var note: String
    var issue: Issue?
    var answeredAt: Date?
}
```

A run stores its own results. Editing a template later never rewrites completed runs — a signed
report must stay reproducible.

## Flow

```
Location detail → [Checklist] → pick a template (recent first)
  → One row per item: [✓ Pass] [✕ Fail] [– N/A]  + note  + camera
  → Fail → camera opens if requiresPhotoOnFail → issue sheet prefilled:
      title = item text, severity = defaultSeverity, location = current
  → Header progress "14/22"; finish enabled at 100% answered
```

- **One tap per item in the common case** — pass has no follow-up.
- Fail flows into the existing issue editor ([03](03-issue-tracking.md)) — no parallel data path, no
  second kind of defect record.
- Unanswered items are visible and block completion, but never block leaving the screen.
- Runs are resumable; sessions get interrupted.

## Seeded templates

Built-ins ship with the app: editable and duplicable, not deletable. User edits fork a copy.

| Template | Items |
|---|---|
| Apartment handover — living room | ~18 |
| Apartment handover — bedroom | ~14 |
| Apartment handover — bathroom | ~16 |
| Apartment handover — kitchen | ~15 |
| Apartment handover — balcony and windows | ~10 |
| Electrical and outlets | ~12 |
| Plumbing and drainage | ~12 |
| Structural — walls, floors, ceilings | ~14 |

## Reporting

The PDF ([05](05-reporting.md)) gains a per-location checklist table: item, outcome, note, and the
generated issue reference. This is what makes a handover record complete — it shows what was checked
and passed, not only what failed.

```swift
enum ChecklistConstants {
    static let maxItemsPerTemplate: Int = 200
    static let recentTemplateCount: Int = 5
    static let templateExportVersion: Int = 1
}
```

## Known risks

| Risk | Handling |
|---|---|
| Template edited after runs exist | Runs keep their own results; the report renders from the run |
| Tick-through without inspecting | Not solvable in software; each answer is timestamped, so a 22-item run in 30 seconds is visible |
| Template sprawl | Sort by `usageCount`, cap items, prefer duplicate-and-edit over new-from-scratch |
| Untrusted imported JSON | Validate `templateExportVersion`, cap item counts, treat all text as data |

## Definition of done

- Run a 22-item template offline; two fails create two issues with prefilled fields.
- Kill mid-run; relaunch resumes with answers intact.
- Editing the template afterwards leaves the completed run and its PDF section unchanged.
- Checklist results appear in the PDF grouped under their location.
- Zero warnings.

## Tests

| Test | Kind |
|---|---|
| Fail creates exactly one issue with the item's text and default severity | unit |
| Changing fail → pass resolves the generated issue, never orphans it | unit |
| Editing a template does not alter existing run results | unit |
| Completion percentage across pass/fail/NA/unanswered | unit |
| JSON import rejects wrong version and oversized payloads | unit |
| Built-ins load; user edits fork rather than mutate | unit |
