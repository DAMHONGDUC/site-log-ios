# 00 — UI design plan (Figma)

Screen inventory and Figma file structure for the whole app, derived from `docs/feature-docs/`.

## 1. Design principles

- One-handed, thumb-reach: primary actions (camera, save) in the lower half — [01](../feature-docs/01-project-session.md) §3.
- Readable outdoors and with gloves: min 44pt targets, 17pt body, high-contrast dark and light.
- Offline is normal: no blocking spinners; "waiting" is never red — [09](../feature-docs/09-diagnostics.md) §3.
- Camera is the home: sheets return to the camera, not to lists — [03](../feature-docs/03-issue-tracking.md) §3.1.
- Severity colour is the only strong colour: Critical red, Major orange, Minor yellow.

## 1a. Market scan and visual direction

| App | What it does well | Taken for SiteLog |
|---|---|---|
| Fieldwire | Plan-first punch list, pins coloured by status | Pins as the map of remaining work; hollow = resolved |
| PlanRadar | Tickets pinned on drawings, report templates | Report builder with section toggles |
| CompanyCam | Photo-first timeline, markup after every shot | Camera is home; markup opens from the photo |
| SafetyCulture | Big Pass/Fail/N/A answers, one tap per item | Checklist answer row |
| GoAudits | Photo proof before closing, PDF at the end of a walk | Verify flow with 30% overlay; session summary ends in "Create report" |

Most competitors (and most AI-generated UI) share the same look: saturated blue, Inter, pastel pill
chips, big soft cards. SiteLog uses a **field-ledger** look instead:

- White screen background, graphite ink `#16181B` for primary buttons, warm hairline borders
  `#E6E3DD` instead of shadows.
- Hi-vis yellow `#FFD400` only for capture, focus rings and the active session — like a safety vest,
  never as a large fill.
- IBM Plex Sans for UI, IBM Plex Mono for location codes, counts, hashes and timestamps.
- No tinted pill tags. Severity is a marker shape + ink text: Critical ■ red square, Major ▲ amber
  triangle, Minor ○ blue ring; Resolved ● green dot, Waiting ◌ dashed ring. Shapes keep severity
  readable in grayscale and for colour-blind users. Rows add a 3 pt left bar; file types use an
  outlined mono label (`PDF`); only labels over photos get a solid white chip.
- Site photos are drawn as flat architectural scenes, not grey placeholder boxes.

iOS metrics: status bar 54 pt (Dynamic Island), nav bar 44 pt, large title 40 pt line, tab bar
49 + 34 pt, home-indicator safe area 34 pt. Every primary action lives in a bottom dock above the
safe area; sheets carry their own bottom dock.

Tokens: `COLOR_TOKENS` (19 colours, Light + Dark) and `TYPE_TOKENS` (10 text styles with SwiftUI
mapping) at the top of [mockups/index.html](mockups/index.html) are the single source; the page
generates its CSS variables from them and shows them on the Foundations board, with three screens
rendered in Dark to check the values.

Mockups: [mockups/index.html](mockups/index.html) — 35 screens, import into Figma with the
html.to.design plugin (Chrome extension on the opened file).

## 2. Figma file structure

File: [SiteLog — iOS App Design](https://www.figma.com/design/3Ru8x4sFZSQwlFI42wqrbH)

Starter plan limits: 3 pages, 1 variable mode (light only), low MCP call quota.

| Page | Contents |
|---|---|
| 01 Foundations & Components | Cover, colour variables, type scale, spacing/radius, buttons, chips, rows, controls |
| 02 Screens | One Section per group in §3, iPhone 16 frame (393×852) |
| 03 Flows | Flow diagrams for each flow in §3 (not started) |

Figma uses Inter + Material Symbols because SF Pro does not render in the Figma renderer; the app
ships with SF Pro + SF Symbols.

## 3. Screen inventory

| # | Group | Screens | Spec | Milestone |
|---|---|---|---|---|
| S1 | Launch & security | Face ID lock, app-switcher overlay, sign-in | 07, 08 | M4–M5 |
| S2 | Projects | Project list, new project sheet, project detail (Sessions · Locations · Plans tabs) | 01 | M1 |
| S3 | Sessions & locations | Start session sheet, survey screen (location tree + badges), bulk-generate locations, clone tree, end session | 01 | M1 |
| S4 | Capture | Camera, capture review, measurement overlay + device status dot | 02, 06 | M1, M4 |
| S5 | Issues | Issue sheet (severity, assignee, due, dictation), open-issues banner, verification camera with 30% overlay, outcome picker, issue list | 03, 12 | M3 |
| S6 | Annotation | Markup editor (arrow, box, circle, text), stamped image preview | 12 | M4 |
| S7 | Plans | Plan sheet list, plan viewer with pins/clusters, pin preview, plan import | 11 | M4 |
| S8 | Checklists | Template picker, checklist run (Pass/Fail/N/A, progress 14/22) | 13 | M4 |
| S9 | Reports | Report builder (grouping, sections), branding settings, signature pad (two parties), PDF preview + share | 05 | M3 |
| S10 | Uploads & diagnostics | Upload status screen, diagnostic bundle export | 04, 09, 10 | M2 |
| S11 | Settings | Account, devices (BLE pairing), security, storage cleanup, delete account | 06, 07, 08, 09 | M4–M6 |

## 4. Status (2026-09-30)

| Done in Figma | Not yet |
|---|---|
| Foundations, components | Flows page |
| Projects, sessions, locations (7 screens) | Checklists (S8) |
| Capture, issues, before/after (6 screens) | Reports (S9) |
| Annotation, stamps, floor plans (5 screens) | Uploads & diagnostics (S10), security & settings (S1, S11) |

Known fixes: camera screens 2.1/2.3 cut the shutter row at the bottom (viewfinder too tall);
2.4 last button is clipped.

## 5. Order of work

1. Foundations + components (page 01–02).
2. Core flow S2 → S3 → S4 → S5 (matches M1–M3 in [ROADMAP](../../ROADMAP.md)).
3. S9 reports, S10 uploads.
4. S6, S7, S8 field features.
5. S1, S11 security and settings.
6. Dark mode pass, empty/error/offline states for every screen.
