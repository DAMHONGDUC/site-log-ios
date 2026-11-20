# 00 — UI design plan (Figma)

<dl><dd>

- Screen inventory and Figma file structure for the whole app, derived from `docs/feature-docs/`.
- Tokens in code: `Packages/DesignSystem` (`DSColor`, `DSSpacing`, `DSTextStyle`).

</dd></dl>

## Contents

<dl><dd>

1. [Design principles](#1-design-principles)
2. [Market scan and visual direction](#1a-market-scan-and-visual-direction)
3. [Figma file structure](#2-figma-file-structure)
4. [Screen inventory](#3-screen-inventory)
5. [Status](#4-status-2026-11-17)
6. [Order of work](#5-order-of-work)

</dd></dl>

## 1. Design principles

<dl><dd>

- One-handed, thumb-reach: primary actions (camera, save) in the lower half — [01](../feature-docs/01-field-work.md#01-projects-sessions-locations).
- Readable outdoors and with gloves: min 44pt targets, 17pt body, high-contrast dark and light.
- Offline is normal: no blocking spinners; "waiting" is never red — [09](../feature-docs/05-platform.md#091-upload-status-screen).
- Camera is the home: sheets return to the camera, not to lists — [03](../feature-docs/01-field-work.md#031-flows).
- Severity colour is the only strong colour: Critical red, Major amber, Minor blue.

</dd></dl>

## 1a. Market scan and visual direction

<dl><dd>

| App | What it does well | Taken for SiteLog |
|---|---|---|
| Fieldwire | Plan-first punch list, pins coloured by status | Pins as the map of remaining work; hollow = resolved |
| PlanRadar | Tickets pinned on drawings, report templates | Report builder with section toggles |
| CompanyCam | Photo-first timeline, markup after every shot | Camera is home; markup opens from the photo |
| SafetyCulture | Big Pass/Fail/N/A answers, one tap per item | Checklist answer row |
| GoAudits | Photo proof before closing, PDF at the end of a walk | Verify flow with 30% overlay; session summary ends in "Make the report" |

- Most competitors (and most generated UI) look the same: saturated blue, Inter, pastel pill chips,
  big soft cards. SiteLog uses a **field-ledger** look instead:

- White screen background, graphite ink `#16181B` for primary buttons, hairline separators instead
  of borders and shadows.
- Hi-vis yellow `#FFD400` only on the capture button and the live-session dot — like a safety vest,
  never as a large fill.
- Type: SF Pro in the app (Dynamic Type text styles, see `TYPE_TOKENS`); IBM Plex Sans stands in
  for it in Figma and the HTML pages. Monospace (SF Mono in the app, IBM Plex Mono in Figma) only for
  real codes: hashes, file names, report IDs.
- No tinted pill tags. Severity is a dot of the same size and shape, told apart by colour, next to its name in ink:
  Critical ● red, Major ● amber, Minor ● blue; Resolved ● green, Waiting ◌ dashed ring. Because colour alone
  is not readable in grayscale or for colour-blind users, the name (or a count with the name nearby) always goes with the dot.
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
| Nav buttons | 44 pt glass circles / capsules, no bar background |
| Screen title | 28/36 pt (`title` token) |
| Tab bar | 64 pt floating glass capsule, 20 pt from the sides, 26 pt from the bottom |
| Home-indicator safe area | 34 pt |

- iOS 26 Liquid Glass (the app builds with the iOS 26 SDK, so system bars, buttons, sheets and alerts render as glass on iOS 26;
  iOS 18 devices get the classic look automatically). Content runs under the glass; partial sheets float inset with a 40 pt radius.
- **Projects are workspaces (like Slack):** tabs Home · Issues · Sync · You. Home and Issues show only the current project;
  only Home carries the switch (Issues names the project under its title); the switch at the top left (project photo + chevron) opens W1, which lists every project with open / overdue counts and a
  live-walkthrough dot. Sync covers the whole device; You is the account. The app reopens on the last project, and a push or
  deep link for another project switches to it.
- **Home sub-tabs (Sessions · Locations · Plans):** each tab has its own filter button beside the tab row (a badge counts
  active filters). When Home scrolls, the walkthrough card and sync line scroll away and the app bar + tab row stay pinned
  (glass on iOS, the scrolled tint on Android). Each filter sheet starts with Sort by. While filters are on, the filter
  button shows a count badge and the list starts with a result count (no chips or Clear all on the page; change or
  clear filters in the sheet); a filter with no result shows a centred hero with Clear filters. Data: `HOME_FILTERS` (`kit.js`); screens P1s, P1f, P8s, P9s, P9f, P9e and sheets HF1–HF3.
- **Issues filters:** no Open / Closed / All tabs. The app bar carries a two-line title at its leading edge (Issues over the project name)
  and search only. Under it, a chip row: first the main filter chip (icon + badge counting groups set beyond the default
  Status; opens every group at once, F1, sort first), then one chip per group (Status · Severity · Due · Assigned to ·
  Show only); a group chip opens that group alone (F1s), shows its value and fills when set. Filtered: badge + result count (C5f); no match: centred empty state (C5e).
- **Other filters, same pattern (badge + result count, changes in the sheet):** plan viewer layers (M4L: pins by severity, closed issues, grouping);
  walkthrough rooms (P5J jump to a unit; chips All / Not checked / Has issues / Re-check due). Project files keep only
  their segmented control.
- **Filter sheets always end with two equal buttons:** Clear (outline) on the left, Apply (primary) on the right — Home
  tabs, Issues and the plan's Show on plan sheet alike.
- **Team and roles (F19):** one company, four roles (Admin · Manager · Inspector · Viewer). Admins manage members from
  You → Team; Managers add Inspectors and Viewers to a project (Home ⋯ → Members); a Viewer sees a read-only Home and
  issue with a "View only" note instead of action buttons. Rules: site-log-be `docs/feature-docs/05-team-and-roles.md`.
- **Issue assignee:** lists show only the assignee's avatar (20), right of the due date under the severity, right-aligned
  (alone on that line when there is no date); the
  issue detail shows avatar + name in "Assigned to". A member's avatar is their photo or initials; a typed-in
  subcontractor gets initials on a neutral colour.
- Every primary action is a capsule at the bottom over a soft scroll-edge fade, or a floating glass toolbar around the hi-vis capture button; sheets carry their own actions.
- **Tokens:** `COLOR_TOKENS` (17 colours, light + dark) and `TYPE_TOKENS` (8 text styles on 4 sizes, 28 / 20 / 17 / 13, and 2 weights, 400 / 600,
  with SwiftUI and Compose mapping) in [html/tokens.js](html/tokens.js) are the single source; `DesignSystem` (iOS) and
  `:designsystem` (Android) mirror them.
- **HTML pages** (one per Figma page, see §2): [1-foundations](html/1-foundations.html),
  [2-ios](html/2-ios.html) (79 screens), [3-android](html/3-android.html) (the same 79 in Material 3),
  [4-flows](html/4-flows.html) (25 flows), [5-system-design](html/5-system-design.html) (28 components).

</dd></dl>

## 2. Figma file structure

<dl><dd>

- File: [Site Log iOS Design](https://www.figma.com/design/uJZcCP6lzw8QTSkcu8uqvV/Site-Log-iOS-Design) (free plan: 3 pages, 1 variable mode — pages 04 Flows and 05 System design
  need a paid plan or a second file).
- Every page is built as HTML first, in [html/](html/), then rebuilt in Figma as editable layers by the scripts in [figma-sync/](figma-sync/README.md).

| Page | HTML | Contents |
|---|---|---|
| 01 Foundations | [1-foundations.html](html/1-foundations.html) | App icon (iOS masters, Android adaptive layers and masks, Google Play), text styles for both platforms, colour tokens light + dark, spacing scale and layout constants |
| 02 iOS | [2-ios.html](html/2-ios.html) | 79 screens in 13 groups (§3, the last is 6 states), iPhone 16 (393×852), plus 3 dark screens |
| 03 Android | [3-android.html](html/3-android.html) | The same 79 screens in Material 3, Android compact (412×917 dp), plus 3 dark screens |
| 04 Flows | [4-flows.html](html/4-flows.html) | 25 flows drawn with the iOS screens: ringed control → arrow with the action → next screen |
| 05 System design | [5-system-design.html](html/5-system-design.html) | 28 shared components (push notification, plan pin, checklist answer, camera controls, toast, passcode and thumbnail included), each with purpose, `DS…` name, properties (enum-like: `type` · `size` · `state` · slots, each with cases and a default), spec (pt / dp) and one variant row per `property.case`, iOS and Android side by side, drawn by the same CSS as the screens |

- Preview locally: `python3 -m http.server 8765 --directory docs/design`, then open `http://localhost:8765/html/1-foundations.html`.
- Import: [figma-sync](figma-sync/README.md) serialises each page from the local server (the pages load `tokens.js`, `kit.js` and the CSS beside them) and rebuilds it through the Figma MCP.
- Stand-ins in Figma: IBM Plex Sans / Mono for SF Pro / SF Mono (iOS), Inter / JetBrains Mono as shipped (Android),
  Lucide for SF Symbols and Material Symbols.

</dd></dl>

## 3. Screen inventory

<dl><dd>

| # | Group | Screens | Spec | Feature |
|---|---|---|---|---|
| S1 | Launch & security | Face ID lock (A1), passcode unlock (A3), passcode locked (A3l), app-switcher overlay, sign-in (A2) | 07, 08 | F01 (F12 sign-in) |
| S2 | Home & projects | Home tab of the current project (live walkthrough, Sessions · Locations · Plans), project switcher (W1), new project sheet | 01 | F02 |
| S3 | Sessions & locations | Start session sheet, survey screen (location tree + badges), bulk-generate locations, clone tree, end session | 01 | F02 |
| S4 | Capture | Camera, capture review, measurement overlay + device status dot | 02, 06 | F03, F10 |
| S5 | Issues | Issue sheet (severity, assignee, due, dictation), open-issues banner, verification camera with 30% overlay, outcome picker, issue list | 03, 12 | F05 |
| S6 | Annotation | Markup editor (arrow, box, circle, text), stamped image preview | 12 | F06 |
| S7 | Plans | Plan sheet list, plan viewer with pins/clusters, pin preview, plan import | 11 | F08 |
| S8 | Checklists | Template picker, checklist run (Pass/Fail/N/A, progress 14/22) | 13 | F09 |
| S9 | Reports | Report builder (grouping, sections), branding settings, signature pad (two parties), PDF preview + share | 05 | F07 |
| S10 | Uploads & diagnostics | Upload status screen, diagnostic bundle export | 04, 09, 10 | F04, F11, F13 |
| S11 | Settings | Account, devices (BLE pairing), app lock (S4: Lock app + Lock after), set passcode (S5), storage cleanup, delete account | 06, 07, 08, 09 | F01, F10, F11, F12 |
| S12 | Team and roles | Team list (T1), Team offline (T1o), invite (T2), member role and projects (T3), project members (T4), join from invite (T5), invite replaced (T5x), not a member (T6), Viewer read-only Home and issue (T7, T8), not allowed for your role (T8n), team activity (T9) | site-log-be 05 | F19 |
| S13 | Notifications | Why turn them on (N1, first launch after sign-in), system prompt (N2), pushes on the lock screen (N3), notification settings with one switch per kind (N4), notifications off (N4o) | 18 · site-log-be 01-api §10 | F16 (kinds beyond uploads: F19) |

</dd></dl>

## 4. Status (2026-11-17)

<dl><dd>

| Page | HTML | Figma |
|---|---|---|
| 01 Foundations | Done | Up to date (rebuilt 2026-11-21) |
| 02 iOS | Done: 73 screens + 6 states + 3 dark | Stale: 2026-11-17 version; new version uploaded, waiting for the Figma limit |
| 03 Android | Done: 73 screens + 6 states + 3 dark | Stale, same as 02 |
| 04 Flows | Done: 25 flows | Not imported: second file, after the Figma MCP limit resets |
| 05 System design | Done: 28 components | Not imported: second file, after the Figma MCP limit resets |

- The new Figma file replaces the old one (`3Ru8x4sFZSQwlFI42wqrbH`). Import log, what is left and how to resume: [figma-sync/README.md](figma-sync/README.md) (stopped by the Starter plan limit, 20 MCP calls a month).
- States designed (E1–E6): first launch, offline, first sync, sync paused, nothing open, search with recents.
- Redesigned with the mobile-app-ui-design rules (2026-11-17): 4 sizes / 2 weights, spacing on the 4 / 8 pt grid,
  controls at least 44 pt (iOS) / 48 dp (Android), text contrast at least 4.5:1 (`text/tertiary` #868A91 and
  `severity/major` #B35F00 changed). `DSColor`, `DSTextStyle` and `DSSpacing` in both apps still hold the old values
  (`DSSpacing` has ~30 steps such as 5, 9, 11, 13, 22; the scale is now 12 steps, `SPACING_TOKENS`).
- Flows live on their own page (04, `4-flows.html`), drawn with the iOS screens; pages 02 and 03 show only UI.
  The iOS screens are defined once in `ios-screens.js`, used by both 02 and 04. Flows are `FLOWS` in `4-flows.html`, drawn
  by `drawFlows` in `kit.js`; each tapped control has a blue ring (annotation, not a token).

</dd></dl>

## 5. Order of work

<dl><dd>

- Design runs ahead of the features in [ROADMAP](../ROADMAP.md).
- UI skeleton (~30% of Figma, every screen on fake data) — done 2026-10-08.
- Each feature (F01–F15) wires its skeleton screens to view models; the finish to Figma, dark mode pass and
  empty/error/offline states are F16, last.

</dd></dl>
