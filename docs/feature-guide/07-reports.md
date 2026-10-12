# F07 — Reports and audit log

<dl><dd>

- F07 · 31h · skeleton guide — full code is added when this feature starts.

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain — Report types](#1-domain--report-types)
4. [2. Fake data — In-memory reports](#2-fake-data--in-memory-reports)
5. [3. View models — Wire the report flow](#3-view-models--wire-the-report-flow)
6. [4. Real data — CSV, PDF, audit chain](#4-real-data--csv-pdf-audit-chain)
7. [Tests (after the feature works)](#tests-after-the-feature-works)
8. [Feature done](#feature-done)

</dd></dl>

## Overview

<dl><dd>

- **Goal:** Reports and audit log end to end: Domain → fake data → view models → real data → tests.
- **Demo:** signed, branded PDF and CSV from a real session, shared in airplane mode; audit chain verifies.
- **Spec:** [05](../feature-docs/04-reporting-security.md#05-pdf-and-spreadsheet-export), [07.3 audit](../feature-docs/04-reporting-security.md#073-audit-log)
- **Starts from:** the skeleton screens (~30% of Figma) that read `App/Fakes/FakeData.swift`.
- **Fakes:** only in `Packages/DataLayer/Sources/DataLayer/Fakes/`, registered in `AppDependencies`; the dev menu seeds / clears them through `FakeDevDataActions`.
- **File tags:** <b class="tag-new">New</b> create the file · <b class="tag-edit">Edit</b> change only the part shown.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--report-types) | Domain | 1h | not start | Report types |
| [2](#2-fake-data--in-memory-reports) | Fake data | 1h | not start | In-memory reports |
| [3](#3-view-models--wire-the-report-flow) | View models | 4h | not start | Wire the report flow |
| [4](#4-real-data--csv-pdf-audit-chain) | Real data | 25h | not start | CSV, PDF, audit chain |

<details open>
<summary><strong>Order</strong></summary>
<dl><dd>

- Steps run top to bottom; the app runs after every step.
- Real data changes only registrations in `AppDependencies`, never views or view models.
- Tests come last, once the feature works end to end.

</dd></dl>
</details>

</dd></dl>

## Target structure

<dl><dd>

```text
Packages/
├── DomainLayer/Sources/DomainLayer/Reporting/, Security/AuditEntry.swift  # 1
├── DataLayer/Sources/DataLayer/Fakes/                           # 2: InMemoryReportRepository
└── DataLayer/Sources/DataLayer/DataSources/Local/Reporting/     # 4: ReportLayoutEngine (pure), PDFPageRenderer, CSVWriter
SiteLog/
└── Presentation/Reports/                                        # 3: ReportBuilder, Branding, SignaturePad, PDFPreview
```

</dd></dl>

## 1. Domain — Report types

<dl><dd>

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Packages/DomainLayer/Sources/DomainLayer/Reporting/` | `SessionSnapshot`, `ReportOptions`, `ReportBranding`, `Signature` |
| <b class="tag-new">New</b> | `Packages/DomainLayer/Sources/DomainLayer/Security/AuditEntry.swift` | Audit entry |

</dd></dl>

## 2. Fake data — In-memory reports

<dl><dd>

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Packages/DataLayer/Sources/DataLayer/Fakes/InMemoryReportRepository.swift` | Branding, options, a snapshot of the sample session; a fixed sample PDF |
| <b class="tag-edit">Edit</b> | `SiteLog/App/AppDependencies.swift` | Registers the fake; the real step only changes this line |

#### Steps

<dl><dd>

1. Implement the Domain protocol as an `actor` that keeps everything in memory.
2. Seed it with Eastline branding and R-0930-07 — move the values out of `App/Fakes/FakeData.swift`.
3. Add `reset()` (empty) and `seed()`; `FakeDevDataActions` calls them from the dev menu.
4. Register it in `AppDependencies`.

</dd></dl>

</dd></dl>

## 3. View models — Wire the report flow

<dl><dd>

| Action | Skeleton folder | View model work |
|---|---|---|
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Reports/ReportBuilder/` | R2: grouping, sections |
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Reports/Branding/` | R3: letterhead |
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Reports/SignaturePad/` | R4: two parties (PencilKit) |
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Reports/PDFPreview/` | R5: preview, estimated size, share |

#### Steps

<dl><dd>

1. Add `<Screen>ViewModel.swift` next to the view: `@MainActor @Observable`, use cases through `@Injected`.
2. In the view, replace `FakeData…` with view-model state; keep the layout (visual finish is F16).
3. Loading, empty (`SDEmptyState`) and error states; previews for each.
4. Delete this feature's `Fake*` types from `App/Fakes/FakeData.swift` once nothing uses them.

</dd></dl>

</dd></dl>

## 4. Real data — CSV, PDF, audit chain

<dl><dd>

<details open>
<summary><strong>4.1 Report data model and CSV</strong></summary>
<dl><dd>

- **Goal:** one-fetch `SessionSnapshot` and streamed CSV.
- **Spec:** [05](../feature-docs/04-reporting-security.md#05-pdf-and-spreadsheet-export)

#### Steps

<dl><dd>

1. CSV columns from spec 05; stream with `FileHandle`.

</dd></dl>
</details>

<details open>
<summary><strong>4.2 PDF renderer</strong></summary>
<dl><dd>

- **Goal:** paginated PDF that never drops an image.
- **Spec:** [05.2](../feature-docs/04-reporting-security.md#052-rendering)

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Reporting/ReportLayoutEngine.swift` | Pure; counts images |
| <b class="tag-new">New</b> | `Reporting/PDFPageRenderer.swift` | `UIGraphicsPDFRenderer`, one autoreleasepool per page |

</dd></dl>

#### Steps

<dl><dd>

1. Split this part when you start (layout · render · integrity footer).
2. Temp file + atomic move.

</dd></dl>
</details>

<details open>
<summary><strong>4.3 Audit chain</strong></summary>
<dl><dd>

- **Goal:** HMAC-chained audit log, verified at launch.
- **Spec:** [07.3](../feature-docs/04-reporting-security.md#073-audit-log)

</dd></dl>

#### Steps

<dl><dd>

1. Key generated once, Keychain only.
2. Verify step runs async after `.ready`.

</dd></dl>
</details>

<details open>
<summary><strong>4.4 Real logic behind the screens</strong></summary>
<dl><dd>

- **Goal:** real issues, lock and reports; export from a real session.

| Action | File | Holds |
|---|---|---|
| <b class="tag-edit">Edit</b> | `SiteLog/App/AppDependencies.swift` | Swap the fake registrations for the real ones |

</dd></dl>

#### Steps

<dl><dd>

1. Register real repositories, Keychain lock, renderer.

</dd></dl>

#### Done when

<dl><dd>

- Before/after pair in the PDF
- Signed PDF + CSV shared in airplane mode
- App lock uses Keychain + Face ID

</dd></dl>
</details>

</dd></dl>

</dd></dl>

## Tests (after the feature works)

<dl><dd>

**4. Real data — CSV, PDF, audit chain**

- CSV escaping
- Both groupings give the same total
- Image count = non-excluded captures
- 200-image memory under 200 MB
- Hash-of-hashes order-stable
- 100-entry chain verifies
- Edit at 50 / mid-chain delete detected at the right index

</dd></dl>

## Feature done

<dl><dd>

| Check | How |
|---|---|
| Demo | Signed PDF + CSV from a real session, before/after pairs included |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F07 steps ticked |

</dd></dl>
