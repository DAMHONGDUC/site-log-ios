# 11 — Floor plans & issue pins

Modules: `Packages/Plans`, `App/Features/Plans`

The defining feature of the category ([00](00-project-info.md) §2). A location
code says "A-12.05"; a pin on a drawing says *there*, and removes the argument.

## 1. Goal

Import a floor plan, pin issues onto exact coordinates, print a per-floor pin map in the report.

## 2. Scope

| In | Out |
|---|---|
| Import from PDF (multi-page) or image | DWG/CAD parsing |
| Per-`Location` plan assignment | Measurement and scaling tools |
| Pin drop, drag, delete | Plan version comparison |
| Pan/zoom viewer, clustering at low zoom | Editing the plan itself |
| Pin ↔ issue navigation | |
| Pin map pages in the PDF ([05](05-reporting.md)) | |

## 3. Model

```swift
@Model final class PlanSheet {
    var id: UUID
    var project: Project
    var name: String              // "Floor 3", "Block B — Level 2"
    var sourceFileURL: URL        // relative path
    var pageIndex: Int            // 0 for images
    var pixelSize: CGSize
    var sha256: String            // plans are evidence too
    var location: Location?
}

@Model final class PlanPin {
    var id: UUID
    var sheet: PlanSheet
    var issue: Issue
    var normalizedPoint: CGPoint  // 0...1 in both axes
    var createdAt: Date
}
```

- **`normalizedPoint` is 0…1, never pixels.** Pixel coordinates break when the plan re-renders at a
  different scale or the device changes.
- One `Issue` has at most one `PlanPin`. Pins are mutable; every move writes an audit entry
  ([07](07-security.md)).

## 4. Rendering

| Concern | Approach |
|---|---|
| Large plans (A0 at 300 dpi) | `CATiledLayer`, tiles rendered on demand — never the full bitmap |
| Source | `PDFKit` for PDF, `CGImageSource` for images |
| Tile cache | `<Caches>/plans/<sheetID>/`, evictable |
| Pins | Overlay `UIView` above the tiled layer, never drawn into the bitmap |
| Zoom | `UIScrollView`, bounds from `PlanConstants` |

Fieldwire's documented weakness is sync lag on large plan sets. Plans are imported once and cached
on disk; the app never re-downloads a plan to display it.

```swift
func planPoint(from viewPoint: CGPoint, in view: PlanView) -> CGPoint {
    let content = view.convert(viewPoint, to: view.contentLayer)
    return CGPoint(x: content.x / view.contentLayer.bounds.width,
                   y: content.y / view.contentLayer.bounds.height)
}
```

## 5. Interaction

```
Location detail → [Plan] tab
  → Long-press → pin drops → issue sheet (03)
  → Tap a pin → issue preview → [Open]
  → Drag a pin → confirm on release
```

- **Long-press to drop, not tap** — tapping is how users pan and inspect; accidental pins are worse
  than a slower gesture.
- Pin color follows `severity`; the label is the issue's sequence within the sheet.
- Below `clusterZoomThreshold`, overlapping pins collapse into a count badge.
- `.resolved` issues render hollow, so a walkthrough shows remaining work at a glance.

## 6. Import

1. Source: Files, or the share sheet from email.
2. Multi-page PDFs prompt for pages; each becomes one `PlanSheet`.
3. Hash on import, store under `<AppSupport>/plans/<projectID>/`.
4. Uploads via [UploadKit](04-upload-engine.md) at low priority.
5. Cap at `maxPlanFileBytes`; larger files rejected with the actual size stated.

```swift
enum PlanConstants {
    static let maxPlanFileBytes: Int64 = 100 * 1024 * 1024
    static let maxZoomScale: CGFloat = 8
    static let minZoomScale: CGFloat = 1
    static let clusterZoomThreshold: CGFloat = 2
    static let clusterRadiusPoints: CGFloat = 24
    static let pinDropLongPressDuration: TimeInterval = 0.4
    static let tileSize: CGSize = CGSize(width: 512, height: 512)
    static let uploadPriority: Int = 1
}
```

## 7. Known risks

| Risk | Handling |
|---|---|
| Plan replaced by a revised drawing | Never overwrite — import a new `PlanSheet`, offer to migrate pins by normalized coordinate, keep the old sheet |
| Password-protected or corrupt PDF | Detected at import with a stated reason; never a silent blank viewer |
| Very large plans | Tiled rendering + hard size cap; verified with an A0 fixture |
| Pinning on the wrong sheet | Sheet name pinned to the viewer top and printed under every pin map |

## 8. Definition of done

- Import a 20-page A1 PDF, pin 50 issues, pan and zoom at 60fps on device.
- Peak memory viewing an A0 plan under 150 MB.
- Pins survive relaunch and land on the same physical spot at a different zoom.
- Import and pinning work fully offline.
- Zero warnings; builds independently.

## 9. Tests

| Test | Kind |
|---|---|
| `planPoint(from:in:)` round-trips through zoom and pan | unit, pure |
| Normalized coordinates map to the same point at two render scales | unit |
| Clustering groups within `clusterRadiusPoints`, splits above the threshold | unit |
| Import rejects oversized and encrypted PDFs with distinct errors | unit |
| Pin migration between sheet revisions preserves relative position | unit |
| Deleting an issue removes its pin; deleting a sheet blocks while pins exist | unit |
| A0 render peak memory | performance |
