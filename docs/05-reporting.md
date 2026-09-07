# 05 — PDF & spreadsheet export

Module: `Packages/Reporting`

The paid deliverable. Never truncated, never missing images, never crashing on page 38 of 40.

## Goal

Turn a `Session` into a branded, signed PDF plus a CSV/XLSX, shareable on the spot, with no network.

## Scope

| In | Out |
|---|---|
| Branded cover (logo, client block) | Fully custom per-company layouts (v2) |
| Summary by severity, floor, assignee | PKI digital signatures — these are captured handwritten signatures with internal acceptance value only, and the app must say so |
| Plan pin maps per sheet ([11](11-floorplan-pins.md)) | |
| Checklist result tables ([13](13-checklists.md)) | |
| Issue blocks with annotated photos | |
| Before/after pairs, stale-issue section | |
| Signature page, two parties | |
| Footer: report ID, page, hash prefix, verification code | |
| Grouping by location or by assignee | |
| PDF + CSV/XLSX, share via Files / `UIActivityViewController` | |

## Sections

| Section | Source |
|---|---|
| Cover — project, client, dates, surveyor, logo | Project + `ReportBranding` |
| Summary — counts by severity, floor, assignee | Issues |
| Plan pin maps — one page per `PlanSheet` | [11](11-floorplan-pins.md) |
| Checklist results — item / outcome / note per location | [13](13-checklists.md) |
| Issue detail — annotated photos, severity, assignee, due date | [03](03-issue-tracking.md), [12](12-annotation.md) |
| Before/after pairs | [03](03-issue-tracking.md) |
| Stale issues | Issues |
| Signatures | This spec |

Grouping is a parameter, not a second code path: `by location` (how the walk happens) or
`by assignee` (how the work is handed out).

## Branding

```swift
struct ReportBranding: Codable, Sendable {
    let companyName: String
    let logoFileURL: URL?
    let accentColorHex: String
    let clientBlock: String
    let footerNote: String
}
```

Stored per user, synced with metadata. Even free competitors ship branded exports
([00-project-info.md](00-project-info.md)); a report that looks like a form template undercuts what
the user can charge.

## Spreadsheet export

CSV always; XLSX above `csvOnlyRowThreshold`. One row per issue:

```
report_id, project, session_date, location_code, plan_sheet, pin_x, pin_y,
issue_id, title, detail, severity, status, assignee, trade, due_date,
capture_count, first_capture_sha256, verification_code, created_at
```

Streamed with `FileHandle`, never built as one string. This is what the site office pastes into
their own tracker.

## Rendering

`UIGraphicsPDFRenderer`. No third-party library, no WebView printing — HTML→PDF depends on image
load timing and with 200 images produces blank pages or extreme slowness.

```
SessionSnapshot → ReportLayoutEngine → [ReportPage] → PDFPageRenderer → PDF
                  (pure, no UIKit)                     (UIKit drawing)
```

| Rule | Reason |
|---|---|
| Layout counts images, renderer draws them | The only way to guarantee no dropped evidence |
| `CGImageSourceCreateThumbnailAtIndex`, never `UIImage` + resize | 160 full-size images = jetsam |
| Downsample to printed cell size (`maxImagePixelSize`) | |
| One `autoreleasepool` per page | |
| Background queue; `@MainActor` receives progress only | |
| Render to temp, then `moveItem` | A kill mid-render never surfaces a partial file |

```swift
for (index, page) in pages.enumerated() {
    autoreleasepool {
        context.beginPage()
        renderer.draw(page, in: context)
    }
    await progress.send(Double(index + 1) / Double(pages.count))
}
```

## Signatures

- `PencilKit` (`PKCanvasView`) or a hand-rolled `UIBezierPath`.
- Transparent PNG embedded on the final page, with `signedAt`, `signerName`, `signerRole` per party.
- Signing sets `Session.state = .exported`; the session becomes read-only.
- Re-signing creates a `-R2` revision; the original is preserved.

## Integrity

- Under each image: first 8 hash characters, the server verification code when synced, and the time
  confidence when below `.serverVerified` ([12](12-annotation.md) §5–6).
- Final page: SHA-256 over the `captureID`-sorted hash list.
- Images render from the **stamped, annotated derivative**; the archive keeps the clean original.
- Unsynced captures print "not yet verified", never a fabricated code.

```swift
enum ReportConstants {
    static let pageSize: CGSize = CGSize(width: 595, height: 842)   // A4 @72dpi
    static let margin: CGFloat = 40
    static let imagesPerRow: Int = 2
    static let maxImagePixelSize: CGFloat = 1400
    static let jpegCompressionQuality: CGFloat = 0.8
    static let hashPrefixLength: Int = 8
    static let staleIssueSessionThreshold: Int = 3
    static let csvOnlyRowThreshold: Int = 5000
    static let maxLogoPixelSize: CGFloat = 600
}
```

All spacing, color, and type come from `DesignSystem` tokens, including inside the PDF.

## Known risks

| Risk | Handling |
|---|---|
| Killed mid-render | Temp file + atomic move |
| Referenced image missing from disk | Placeholder block "Image no longer on device — {hash}". Never crash, never silently skip |
| Non-ASCII filenames | `addingPercentEncoding` on share; test with "Ánh Dương – Block B" |
| Reports too large to send over chat apps | Show estimated size before export, offer a compression level |

## Definition of done

- 200 images / 40 issues exports on a low-end iPhone with peak memory under 200 MB.
- Image count equals non-excluded capture count, asserted by test.
- Before/after pairs correctly matched and ordered, each labeled with `Location.code`.
- Export succeeds in airplane mode.
- Zero warnings.

## Tests

| Test | Kind |
|---|---|
| Rendered image count equals input capture count | unit, pure |
| Empty / 1 issue / 500 issues → no crash, sane page count | unit |
| A 20-image issue paginates without overflow | unit |
| Missing file → placeholder, no throw | unit |
| Hash-of-hashes stable under input reordering | unit |
| Grouping by assignee and by location give the same issue total | unit |
| CSV escapes quotes, commas, newlines in user text | unit |
| Unsynced capture renders "not yet verified" | unit |
| Plan pin numbering matches the detail section | unit |
| 200-image render peak memory | performance |
| Opens in Preview and Acrobat without font errors | manual |
