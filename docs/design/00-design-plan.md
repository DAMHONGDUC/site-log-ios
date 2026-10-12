# 00 — UI design plan (Figma)

<dl><dd>

- Screen inventory and Figma file structure for the whole app, derived from `docs/feature-docs/`.
- Tokens in code: `Packages/SystemDesign` (`SDColor`, `SDFont`, `SDSpacing`, `SDRadius`, `SDSize`).

</dd></dl>

## Contents

<dl><dd>

1. [Design principles](#1-design-principles)
2. [Market scan and visual direction](#1a-market-scan-and-visual-direction)
3. [Figma file structure](#2-figma-file-structure)
4. [Screen inventory](#3-screen-inventory)
5. [Status](#4-status-2026-09-30)
6. [Order of work](#5-order-of-work)

</dd></dl>

## 1. Design principles

<dl><dd>

- One-handed, thumb-reach: primary actions (camera, save) in the lower half — [01](../feature-docs/01-field-work.md#01-projects-sessions-locations).
- Readable outdoors and with gloves: min 44pt targets, 17pt body, high-contrast dark and light.
- Offline is normal: no blocking spinners; "waiting" is never red — [09](../feature-docs/05-platform.md#091-upload-status-screen).
- Camera is the home: sheets return to the camera, not to lists — [03](../feature-docs/01-field-work.md#031-flows).
- Severity colour is the only strong colour: Critical red, Major orange, Minor yellow.

</dd></dl>

## 1a. Market scan and visual direction

<dl><dd>

| App | What it does well | Taken for SiteLog |
|---|---|---|
| Fieldwire | Plan-first punch list, pins coloured by status | Pins as the map of remaining work; hollow = resolved |
| PlanRadar | Tickets pinned on drawings, report templates | Report builder with section toggles |
| CompanyCam | Photo-first timeline, markup after every shot | Camera is home; markup opens from the photo |
| SafetyCulture | Big Pass/Fail/N/A answers, one tap per item | Checklist answer row |
| GoAudits | Photo proof before closing, PDF at the end of a walk | Verify flow with 30% overlay; session summary ends in "Create report" |

- Most competitors (and most generated UI) look the same: saturated blue, Inter, pastel pill chips,
  big soft cards. SiteLog uses a **field-ledger** look instead:

- White screen background, graphite ink `#16181B` for primary buttons, hairline separators instead
  of borders and shadows.
- Hi-vis yellow `#FFD400` only on the capture button and the live-session dot — like a safety vest,
  never as a large fill.
- Type: SF Pro in the app (Dynamic Type text styles, see `TYPE_TOKENS`); IBM Plex Sans stands in
  for it in Figma and the mockups. Monospace (SF Mono in the app, IBM Plex Mono in Figma) only for
  real codes: hashes, file names, report IDs.
- No tinted pill tags. Severity is a marker shape + ink text: Critical ■ red square, Major ▲ amber
  triangle, Minor ○ blue ring; Resolved ● green dot, Waiting ◌ dashed ring. Shapes keep severity
  readable in grayscale and for colour-blind users.
- Site photos are drawn as flat architectural scenes, not grey placeholder boxes.

**What keeps it from looking generated**

- Native iOS structure: plain full-bleed lists with inset hairlines, sentence-case section headers
  with a grey count on the right, `.body` 17 pt row titles. No card around every block, no
  uppercase mono eyebrow labels.
- One focal element per screen. Summaries are written as sentences ("14 open issues, 2 of them
  overdue") instead of three equal stat boxes.
- Realistic, uneven data in the supervisor's voice: 37 of 82 rooms, "Tuan's masonry crew",
  "due Fri", "2 days late".
- Real iOS details: keyboard up on the new-project sheet, badge on the Issues tab, radio list for
  the re-check outcome, native alert for account deletion, capture button in a bottom toolbar.
- Icons only where they help scanning (tab bar, toolbars, camera), not on every row.

| iOS metric | Value |
|---|---|
| Status bar (Dynamic Island) | 54 pt |
| Nav bar | 44 pt |
| Large title | 34/41 pt |
| Tab bar | 49 + 34 pt |
| Home-indicator safe area | 34 pt |

- Every primary action lives in a bottom dock or toolbar above the safe area; sheets carry their own dock.
- **Tokens:** `COLOR_TOKENS` (17 colours, light + dark) and `TYPE_TOKENS` (10 text styles with SwiftUI
  mapping) at the top of [mockups/index.html](mockups/index.html) are the single source; `SystemDesign`
  mirrors them in Swift.
- **Mockups:** [mockups/index.html](mockups/index.html) — 38 screens; import into Figma with the
  html.to.design plugin.

</dd></dl>

## 2. Figma file structure

<dl><dd>

- File: [SiteLog — iOS App Design](https://www.figma.com/design/3Ru8x4sFZSQwlFI42wqrbH)

- Starter plan limits: 3 pages, 1 variable mode (light only), low MCP call quota.

| Page | Contents |
|---|---|
| 01 Foundations & Components | Cover, colour variables, type scale, spacing/radius, buttons, chips, rows, controls |
| 02 Screens | One Section per group in §3, iPhone 16 frame (393×852) |
| 03 Flows | Flow diagrams for each flow in §3 (not started) |

- Figma and the mockups use IBM Plex Sans / Mono and Lucide icons (SF Pro and SF Symbols do not
  render there); the app ships SF Pro, SF Mono and SF Symbols.

</dd></dl>

## 3. Screen inventory

<dl><dd>

| # | Group | Screens | Spec | Feature |
|---|---|---|---|---|
| S1 | Launch & security | Face ID lock (A1), passcode unlock (A3), app-switcher overlay, sign-in (A2) | 07, 08 | F01 (F12 sign-in) |
| S2 | Projects | Project list, new project sheet, project detail (Sessions · Locations · Plans tabs) | 01 | F02 |
| S3 | Sessions & locations | Start session sheet, survey screen (location tree + badges), bulk-generate locations, clone tree, end session | 01 | F02 |
| S4 | Capture | Camera, capture review, measurement overlay + device status dot | 02, 06 | F03, F10 |
| S5 | Issues | Issue sheet (severity, assignee, due, dictation), open-issues banner, verification camera with 30% overlay, outcome picker, issue list | 03, 12 | F05 |
| S6 | Annotation | Markup editor (arrow, box, circle, text), stamped image preview | 12 | F06 |
| S7 | Plans | Plan sheet list, plan viewer with pins/clusters, pin preview, plan import | 11 | F08 |
| S8 | Checklists | Template picker, checklist run (Pass/Fail/N/A, progress 14/22) | 13 | F09 |
| S9 | Reports | Report builder (grouping, sections), branding settings, signature pad (two parties), PDF preview + share | 05 | F07 |
| S10 | Uploads & diagnostics | Upload status screen, diagnostic bundle export | 04, 09, 10 | F04, F11, F13 |
| S11 | Settings | Account, devices (BLE pairing), app lock (S4: Lock app + Lock after), set passcode (S5), storage cleanup, delete account | 06, 07, 08, 09 | F01, F10, F11, F12 |

</dd></dl>

## 4. Status (2026-09-30)

<dl><dd>

| Done in Figma | Not yet |
|---|---|
| Foundations, components | Flows page |
| Projects, sessions, locations (7 screens) | Checklists (S8) |
| Capture, issues, before/after (6 screens) | Reports (S9) |
| Annotation, stamps, floor plans (5 screens) | Uploads & diagnostics (S10), security & settings (S1, S11) |

- Mockup-only, not yet in Figma (2026-10-01): A3 passcode unlock, S4 app lock, S5 set passcode; the S1
  Privacy row opens S4.
- Known fixes: camera screens 2.1/2.3 cut the shutter row (viewfinder too tall); 2.4 last button clipped.

</dd></dl>

## 5. Order of work

<dl><dd>

- Design runs ahead of the features in [ROADMAP](../../ROADMAP.md).
- UI skeleton (~30% of Figma, every screen on fake data) — done 2026-10-08.
- Each feature (F01–F15) wires its skeleton screens to view models; the finish to Figma, dark mode pass and
  empty/error/offline states are F16, last.

</dd></dl>
