# M7 — UI finish

- M7 — UI finish · App Store · 48h · skeleton guide.

## Contents

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [How to finish a screen](#how-to-finish-a-screen)
4. [P80 · Components to Figma](#p80--components-to-figma)
5. [P81 · Access to Figma](#p81--access-to-figma)
6. [P82 · Projects to Figma](#p82--projects-to-figma)
7. [P83 · Capture and issues to Figma](#p83--capture-and-issues-to-figma)
8. [P84 · Markup and plans to Figma](#p84--markup-and-plans-to-figma)
9. [P85 · Checklists and reports to Figma](#p85--checklists-and-reports-to-figma)
10. [P86 · Sync and settings to Figma](#p86--sync-and-settings-to-figma)
11. [P87 · Dark mode, states, imagery](#p87--dark-mode-states-imagery)
12. [P88 · Accessibility re-check and submission](#p88--accessibility-re-check-and-submission)
13. [Milestone done](#milestone-done)

## Overview

- **Goal:** take every screen from the ~30% skeleton to Figma, on real logic, then ship to the App Store.
- **Demo:** every screen matches Figma side by side in light and dark mode; the build is submitted for review.
- **Specs:** [Design plan](../design/00-design-plan.md), [mockups](../design/mockups/index.html), [Figma file](https://www.figma.com/design/3Ru8x4sFZSQwlFI42wqrbH)
- **Starting point:** the UI skeleton (2026-10-08) — every screen, navigation, `FakeData`, placeholders; view models and real logic come from M0–M6.
- **Status:** skeleton — parts, files, order, tests. Filled in when this milestone starts.

| Part | Track | Hours | Status | What |
|---|---|---|---|---|
| [P80](#p80--components-to-figma) | `UI` | 6h | not start | Components to Figma |
| [P81](#p81--access-to-figma) | `UI` | 3h | not start | S1 access screens |
| [P82](#p82--projects-to-figma) | `UI` | 6h | not start | S2–S3 projects, sessions, rooms |
| [P83](#p83--capture-and-issues-to-figma) | `UI` | 6h | not start | S4–S5 camera, capture review, issues |
| [P84](#p84--markup-and-plans-to-figma) | `UI` | 5h | not start | S6–S7 markup, stamp, plans |
| [P85](#p85--checklists-and-reports-to-figma) | `UI` | 6h | not start | S8–S9 checklists, reports |
| [P86](#p86--sync-and-settings-to-figma) | `UI` | 5h | not start | S10–S11 sync, diagnostics, settings |
| [P87](#p87--dark-mode-states-imagery) | `UI` | 5h | not start | Dark mode, empty/error/offline states, imagery |
| [P88](#p88--accessibility-re-check-and-submission) | `Join` | 6h | not start | Accessibility re-check, listing, submission |

### Order

- No contract part: M7 changes how screens look, never what they do.
- P80 first: every screen part uses the finished components.
- P81–P86 in any order; P87 after them; P88 closes the milestone and the roadmap.

## Target structure

```text
Packages/DesignSystem/Sources/DesignSystem/
├── Tokens/                      # P80: tokens checked against Figma variables
└── Components/                  # P80: DSSeverityPicker, DSAnswerRow, DSToggleRow… finished to Figma
SiteLog/
├── Core/Resources/Assets.xcassets/   # P81, P87: app mark, real imagery
└── Presentation/
    ├── Components/              # P83–P84: SitePhoto, PlanDrawing, CameraControls, CaptureToolbar finished
    ├── Access/ Projects/ Capture/ Issues/ Annotation/ Plans/
    ├── Checklists/ Reports/ Uploads/ Diagnostics/ Settings/   # P81–P86: one screen folder at a time
SiteLogTests/Snapshots/          # P80–P87: one snapshot per screen, light + dark
fastlane/Fastfile                # P88: release lane waits for processing
```

## How to finish a screen

| Step | Do |
|---|---|
| 1 | Open the Figma frame and the running screen side by side |
| 2 | Fix spacing, sizes, fonts with tokens only (`DSSpacing`, `DSFont`…); add a token if Figma needs a new value |
| 3 | Swap placeholders and native controls for the designed ones |
| 4 | Check light + dark, small (SE) and large (Pro Max) iPhone, largest Dynamic Type |
| 5 | Record or update the snapshot test, commit per screen |

## P80 · Components to Figma

- **Goal:** the shared components match the Foundations & Components page.
- Severity segmented control with marker shapes, Pass/Fail/N/A answer row, toggle row, radio row.

### Done when

- `DSGallery` matches the components page; snapshot references re-recorded (light + dark)

## P81 · Access to Figma

- **Goal:** A1 Face ID lock, A2 sign in, A3 passcode, privacy overlay match S1.
- App mark from `docs/design/app-icon/`; passcode dots and number pad as designed.

### Done when

- 4 screens match Figma; snapshots added

## P82 · Projects to Figma

- **Goal:** P1–P7, bulk locations, clone tree, end session (R1) match S2–S3.

### Done when

- Every Projects screen matches Figma; snapshots added

## P83 · Capture and issues to Figma

- **Goal:** C1 camera chrome (glass buttons, mode switcher, shutter), capture review, measurement overlay, C2–C6 match S4–S5.

### Done when

- Camera screens checked on device (real viewfinder); snapshots for the non-camera screens

## P84 · Markup and plans to Figma

- **Goal:** markup editor tools and colours, stamped preview, plan list thumbnails, pins and clusters match S6–S7.

### Done when

- Every Annotation and Plans screen matches Figma; snapshots added

## P85 · Checklists and reports to Figma

- **Goal:** K1–K4 and R2–R5 match S8–S9; real PDF preview page styling.

### Done when

- Every Checklists and Reports screen matches Figma; snapshots added

## P86 · Sync and settings to Figma

- **Goal:** U1–U3, S1–S5, storage cleanup and account match S10–S11.

### Done when

- Every Uploads, Diagnostics and Settings screen matches Figma; snapshots added

## P87 · Dark mode, states, imagery

- **Goal:** dark mode pass on every screen; empty, error and offline states; no placeholder imagery left.

### Done when

- No screen shows a placeholder; every list has its empty and error state; dark snapshots pass

## P88 · Accessibility re-check and submission

- **Goal:** the finished UI still passes the P78 accessibility pass; App Store listing and submission.

| File | Holds |
|---|---|
| `fastlane/Fastfile` | `release` lane waits for processing |

### Steps

1. Repeat the P78 checks (Dynamic Type, VoiceOver, contrast) on the finished screens.
2. Store listing, screenshots from the finished UI, privacy answers; submission stays manual.

### Done when

- Accessibility checks pass on the finished UI
- Build submitted for review

## Milestone done

| Check | How |
|---|---|
| Demo | Every screen next to its Figma frame, light and dark |
| Release | App Store submission sent |
| Roadmap | P80–P88 ticked |
