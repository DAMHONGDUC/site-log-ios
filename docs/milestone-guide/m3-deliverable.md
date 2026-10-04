# M3 — Deliverable

- M3 — Deliverable · 91h · skeleton guide.

## Contents

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [P33 · Issue, annotation, report, audit contract](#p33--issue-annotation-report-audit-contract)
4. [P34 · Issue CRUD, carry-over, pairing](#p34--issue-crud-carry-over-pairing)
5. [P35 · Phrase library, dictation, voice notes](#p35--phrase-library-dictation-voice-notes)
6. [P36 · Real app lock](#p36--real-app-lock)
7. [P37 · Audit chain](#p37--audit-chain)
8. [P38 · Annotation model and rendering](#p38--annotation-model-and-rendering)
9. [P39 · Trusted time and stamped derivative](#p39--trusted-time-and-stamped-derivative)
10. [P40 · Report data model and CSV](#p40--report-data-model-and-csv)
11. [P41 · PDF renderer](#p41--pdf-renderer)
12. [P42 · C2 log issue, C5 list, banner](#p42--c2-log-issue-c5-list-banner)
13. [P43 · C3 re-check overlay, C4 outcome](#p43--c3-re-check-overlay-c4-outcome)
14. [P44 · S4 app lock, S5 set passcode](#p44--s4-app-lock-s5-set-passcode)
15. [P45 · Markup editor](#p45--markup-editor)
16. [P46 · Report builder, branding, signature, preview](#p46--report-builder-branding-signature-preview)
17. [P47 · Real logic behind the screens](#p47--real-logic-behind-the-screens)
18. [Milestone done](#milestone-done)

## Overview

- **Goal:** issues with before/after pairs, real app lock, audit chain, annotations, trusted time and the signed PDF + CSV.
- **Demo:** an issue logged and re-checked as a before/after pair; a signed, branded PDF and a CSV from a real session; app lock live.
- **Specs:** [03](../feature-docs/01-field-work.md#03-issues-and-before-after-pairing), [12](../feature-docs/01-field-work.md#12-annotation-and-verifiable-stamps), [05](../feature-docs/04-reporting-security.md#05-pdf-and-spreadsheet-export), [07](../feature-docs/04-reporting-security.md#07-security-and-audit-log)
- **Status:** skeleton — parts, files, order, tests. Full, tested code is added when this milestone starts, built on the real code from the milestone before.

| Part | Track | Hours | Status | What |
|---|---|---|---|---|
| [P33](#p33--issue-annotation-report-audit-contract) | `Contract` | 4h | not start | Issue, annotation, report, audit contract |
| [P34](#p34--issue-crud-carry-over-pairing) | `Logic` | 6h | not start | Issue CRUD, carry-over, pairing |
| [P35](#p35--phrase-library-dictation-voice-notes) | `Logic` | 6h | not start | Phrase library, dictation, voice notes |
| [P36](#p36--real-app-lock) | `Logic` | 8h | not start | Real app lock |
| [P37](#p37--audit-chain) | `Logic` | 5h | not start | Audit chain |
| [P38](#p38--annotation-model-and-rendering) | `Logic` | 6h | not start | Annotation model and rendering |
| [P39](#p39--trusted-time-and-stamped-derivative) | `Logic` | 8h | not start | Trusted time and stamped derivative |
| [P40](#p40--report-data-model-and-csv) | `Logic` | 5h | not start | Report data model and CSV |
| [P41](#p41--pdf-renderer) | `Logic` | 12h | not start | PDF renderer |
| [P42](#p42--c2-log-issue-c5-list-banner) | `UI` | 6h | not start | C2 log issue, C5 list, banner |
| [P43](#p43--c3-re-check-overlay-c4-outcome) | `UI` | 5h | not start | C3 re-check overlay, C4 outcome |
| [P44](#p44--s4-app-lock-s5-set-passcode) | `UI` | 5h | not start | S4 app lock, S5 set passcode |
| [P45](#p45--markup-editor) | `UI` | 5h | not start | Markup editor |
| [P46](#p46--report-builder-branding-signature-preview) | `UI` | 6h | not start | Report builder, branding, signature, preview |
| [P47](#p47--real-logic-behind-the-screens) | `Join` | 4h | not start | Real logic behind the screens |

### Order

- P33 contract first.
- Logic P34–P41 and UI P42–P46 in parallel; P41 needs P39 (stamped derivative).
- P47 joins. P41 is over 8h: split it.

## Target structure

```text
SiteLog/
├── Domain/Issues/, Annotation/, Reporting/, Security/       # P33
├── Data/Security/KeychainAccessRepository.swift             # P36 (replaces the M0 fake)
├── DataSources/Capture/Annotation/, TrustedTime/            # P38–P39
├── DataSources/Reporting/         # P40–P41: ReportLayoutEngine (pure), PDFPageRenderer, CSVWriter
SiteLog/Presentation/
├── Issues/LogIssue/, IssueList/, Recheck/, Outcome/      # P42–P43
├── Settings/AppLock/, SetPasscode/                       # P44
├── Annotation/Editor/                                    # P45
└── Reports/Builder/, Branding/, Signature/, Preview/     # P46
```

## P33 · Issue, annotation, report, audit contract

- **Goal:** entities and protocols for the four features, with fakes.

| File | Holds |
|---|---|
| `Domain/Issues/` | `Issue`, `IssuePairing`, `PairIssuesUseCase` (pure) |
| `Domain/Annotation/` | `AnnotationShape`, `NormalizedPoint` |
| `Domain/Reporting/` | `SessionSnapshot`, `ReportBranding` |
| `Domain/Security/` | `AuditEntry`; extend `AccessSettings` |

### Tests

- `AnnotationShape` Codable round-trip
- Pairing with 0 / 1 / n open issues

## P34 · Issue CRUD, carry-over, pairing

- **Goal:** log issues, surface open ones next session, close by verification photo.
- **Spec:** [03.1–03.2](../feature-docs/01-field-work.md#031-flows)

### Steps

1. Closing creates a new `.verified` issue and links the old one; originals never mutated.
2. Upload priority: critical 100 · major 50 · minor 10.

### Tests

- Closing never mutates prior captures
- Delete-with-open-issues rejected

## P35 · Phrase library, dictation, voice notes

- **Goal:** on-device dictation and a usage-sorted phrase library.
- **Spec:** [12.3](../feature-docs/01-field-work.md#123-dictation-and-voice-notes)

### Steps

1. `SFSpeechRecognizer` with `requiresOnDeviceRecognition = true`; vi + en.
2. Voice note = audio `Capture`.

### Tests

- Phrase ordering tie-break
- Dictation in airplane mode

## P36 · Real app lock

- **Goal:** Keychain + Face ID repository replaces the M0 `InMemoryAccessRepository`.
- **Spec:** [07.2](../feature-docs/04-reporting-security.md#072-app-lock)

| File | Holds |
|---|---|
| `Data/Security/KeychainAccessRepository.swift` | PBKDF2-SHA256, 16-byte salt, lockout counter in Keychain |
| `Data/Security/BiometricAuthenticator.swift` | `LAContext`, biometry-change detection |

### Steps

1. Add `INFOPLIST_KEY_NSFaceIDUsageDescription` in `project.yml`.
2. Change one registration in `AppDependencies`; M0 screens stay as they are.

### Tests

- Hash round-trip, wrong passcode rejected
- Lockout survives relaunch
- Biometry change turns Face ID off

## P37 · Audit chain

- **Goal:** HMAC-chained audit log, verified at launch.
- **Spec:** [07.3](../feature-docs/04-reporting-security.md#073-audit-log)

### Steps

1. Key generated once, Keychain only.
2. Verify step runs async after `.ready`.

### Tests

- 100-entry chain verifies
- Edit at 50 / mid-chain delete detected at the right index

## P38 · Annotation model and rendering

- **Goal:** vector markup layer that never touches the original.
- **Spec:** [12.1](../feature-docs/01-field-work.md#121-annotation-layer)

### Steps

1. Normalized coordinates (0…1).
2. Stroke scales with image width.

### Tests

- Same render at two sizes
- Original never mutated

## P39 · Trusted time and stamped derivative

- **Goal:** `TrustedTimestamp` with confidence; stamped JPEG copies on demand.
- **Spec:** [12.2, 12.4](../feature-docs/01-field-work.md#124-trusted-time)

### Steps

1. Offset from the backend `Date` header.
2. Derived images never hashed, never evidence.

### Tests

- Confidence for fresh / stale offset, clock jump, relaunch
- Stamp snapshot in three orientations

## P40 · Report data model and CSV

- **Goal:** one-fetch `SessionSnapshot` and streamed CSV.
- **Spec:** [05](../feature-docs/04-reporting-security.md#05-pdf-and-spreadsheet-export)

### Steps

1. CSV columns from spec 05; stream with `FileHandle`.

### Tests

- CSV escaping
- Both groupings give the same total

## P41 · PDF renderer

- **Goal:** paginated PDF that never drops an image.
- **Spec:** [05.2](../feature-docs/04-reporting-security.md#052-rendering)

| File | Holds |
|---|---|
| `Reporting/ReportLayoutEngine.swift` | Pure; counts images |
| `Reporting/PDFPageRenderer.swift` | `UIGraphicsPDFRenderer`, one autoreleasepool per page |

### Steps

1. Split this part when you start (layout · render · integrity footer).
2. Temp file + atomic move.

### Tests

- Image count = non-excluded captures
- 200-image memory under 200 MB
- Hash-of-hashes order-stable

## P42 · C2 log issue, C5 list, banner

- **Goal:** issue sheet that returns to the camera; issue list; open-issues banner.
- **Spec:** Mockups C2, C5

| File | Holds |
|---|---|
| `Presentation/Issues/LogIssue/` | Severity default Major, assignee, due |
| `Presentation/Issues/IssueList/` | Grouped by level |

### Steps

1. Severity via `DSStatusMarker` shapes.

### Tests

- View models
- Snapshots

## P43 · C3 re-check overlay, C4 outcome

- **Goal:** verification camera with the 30% ghost and the outcome picker.
- **Spec:** Mockups C3, C4

### Steps

1. Overlay opacity from `IssueDefaults.overlayOpacity`.

### Tests

- View models
- Snapshots

## P44 · S4 app lock, S5 set passcode

- **Goal:** settings screens for Lock app, Lock after, passcode, forgot passcode.
- **Spec:** [07.2](../feature-docs/04-reporting-security.md#072-app-lock)

| File | Holds |
|---|---|
| `Presentation/Settings/AppLock/` | S4 |
| `Presentation/Settings/SetPasscode/` | S5, enter + confirm |

### Steps

1. Turning off or changing requires the current passcode or Face ID.

### Tests

- View models
- Snapshots

## P45 · Markup editor

- **Goal:** arrow, box, circle, pen, text; stamped preview.
- **Spec:** Mockups (annotation board)

### Steps

1. Undo capped at `maxUndoSteps`; commit on exit.

### Tests

- View model undo bounds
- Snapshot

## P46 · Report builder, branding, signature, preview

- **Goal:** build, sign and share the report.
- **Spec:** Mockups (reports board)

| File | Holds |
|---|---|
| `Presentation/Reports/` | Builder, Branding, Signature (PencilKit), Preview + share sheet |

### Steps

1. Show estimated size before sharing.

### Tests

- View models
- Snapshots

## P47 · Real logic behind the screens

- **Goal:** real issues, lock and reports; export from a real session.

| File | Holds |
|---|---|
| `SiteLog/App/AppDependencies.swift` | Swap fake registrations for the real ones |

### Steps

1. Register real repositories, Keychain lock, renderer.

### Done when

- Before/after pair in the PDF
- Signed PDF + CSV shared in airplane mode
- App lock uses Keychain + Face ID

## Milestone done

| Check | How |
|---|---|
| Demo | Issue → re-check → signed PDF + CSV, app lock live |
| Roadmap | P33–P47 ticked |
