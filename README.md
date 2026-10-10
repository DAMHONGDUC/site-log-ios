# SiteLog

<dl><dd>

- Offline-first iOS app for site supervisors: record construction site conditions, export a signed
  PDF inspection report.
- Author: Dam Hong Duc · bundle ID `app.dd.site.log` · App Store: not published.

</dd></dl>

## Contents

<dl><dd>

1. [Getting started](#1-getting-started)
2. [Docs map](#2-docs-map)
3. [Repo layout](#3-repo-layout)

</dd></dl>

## 1. Getting started

<dl><dd>

| Step | Action |
|---|---|
| 1 | `brew install xcodegen swiftlint` |
| 2 | `xcodegen generate` |
| 3 | Open `SiteLog.xcodeproj`, run the `SiteLog` scheme (⌘R) on an iOS 18.6+ simulator; tests ⌘U |
| 4 | Full tooling (VS Code, hot reload, format on save): [05-platform § Dev setup](docs/feature-docs/05-platform.md#dev-setup) |

</dd></dl>

## 2. Docs map

<dl><dd>

| Doc | Contents |
|---|---|
| [ROADMAP.md](ROADMAP.md) | Features F00–F16 in order, steps per layer, hour estimates |
| [feature-guide/](docs/feature-guide/) | One guide per feature (F00–F16): Domain → fake data → view models → real data → tests |
| [00-overview.md](docs/feature-docs/00-overview.md) | Product, stack, data model, architecture, conventions, decisions D01–D08 |
| [01-field-work.md](docs/feature-docs/01-field-work.md) | 01 Projects · 02 Capture · 03 Issues · 06 DeviceLink · 11 Plans · 12 Annotation · 13 Checklists |
| [02-upload-sync.md](docs/feature-docs/02-upload-sync.md) | 04 Upload engine · 08 Auth and sync · 10 Realtime |
| [03-backend.md](docs/feature-docs/03-backend.md) | 14 Backend: Node, Postgres, sync, WebSocket |
| [04-reporting-security.md](docs/feature-docs/04-reporting-security.md) | 05 PDF and CSV export · 07 Security and audit log |
| [05-platform.md](docs/feature-docs/05-platform.md) | Dev setup · 09 Diagnostics · Testing · 17 CI/CD · 18 Push and deep links · 19 Instruments |
| [00-design-plan.md](docs/design/00-design-plan.md) | Design principles, tokens, screen inventory; [mockups](docs/design/mockups/index.html) |

- Docs rule: content sits indented under its title. After editing any `.md`, run `python3 Tools/Docs/indent-md.py` (wraps sections in `<dl><dd>`; safe to re-run).

</dd></dl>

## 3. Repo layout

<dl><dd>

- Architecture: Clean Architecture + MVVM; `DomainLayer`, `DataLayer`, `Core`, `DesignSystem` are local Swift packages; the app target holds `App/` and `Presentation/`.
- Every folder below already exists (empty ones hold a `.gitkeep`); files arrive feature by feature.

```
site-log-ios/
├── SiteLog/                              # app target: composition root + Presentation
│   ├── App/                              # composition root: may use every layer
│   │   ├── SiteLogApp.swift              # @main
│   │   ├── AppDelegate.swift
│   │   ├── AppDependencies.swift         # Factory registrations
│   │   ├── Startup/
│   │   │   ├── StartupSequence.swift
│   │   │   └── Steps/                    # Crashlytics, Keychain, ModelContainer, UploadReconcile,
│   │   │                                 # AuditVerify, OrphanSweep
│   │   ├── Config/                       # *.xcconfig, entitlements, GoogleService-Info.plist (CI)
│   │   ├── Fakes/                        # UI skeleton sample data; shrinks as each feature lands
│   │   └── Resources/                    # Assets.xcassets, Localizable.xcstrings, seeded templates
│   └── Presentation/                     # MVVM: View + ViewModel; 2+ screens → 1 folder / screen
│       ├── Root/  MainTab/  Components/
│       ├── Access/                       # Startup/ SignIn/ FaceIDLock/ PasscodeUnlock/ PrivacyOverlay/
│       ├── Projects/                     # ProjectList/ NewProject/ ProjectDetail/ StartSession/
│       │                                 # Survey/ BulkLocations/ CloneTree/ EndSession/
│       ├── Capture/                      # Camera/ CaptureReview/
│       ├── Issues/                       # IssueSheet/ IssueList/ VerificationCamera/ OutcomePicker/
│       ├── Annotation/                   # MarkupEditor/ StampPreview/
│       ├── Plans/                        # PlanList/ PlanViewer/ PinPreview/ PlanImport/
│       ├── Checklists/                   # TemplatePicker/ ChecklistRun/
│       ├── Reports/                      # ReportBuilder/ Branding/ SignaturePad/ PDFPreview/
│       ├── Uploads/                      # UploadStatus/
│       ├── Diagnostics/                  # DiagnosticExport/
│       ├── Settings/                     # Account/ Devices/ AppLock/ SetPasscode/ StorageCleanup/
│       ├── Notifications/
│       └── DeepLinks/
├── Packages/                             # local Swift packages: Sources/<Name>/ + Tests/<Name>Tests/
│   ├── DomainLayer/                      # Foundation only
│   │   └── Sources/DomainLayer/
│   │       ├── Entities/                 # Project, Session, Location, Capture, Issue, Annotation,
│   │       │                             # PlanSheet, PlanPin, ChecklistTemplate/Run/Result
│   │       ├── UseCases/                 # <Verb><Noun>UseCase
│   │       └── Repositories/             # protocols
│   ├── DataLayer/                        # implements Domain; uses Domain + Core
│   │   └── Sources/DataLayer/
│   │       ├── Repositories/             # SwiftData<X>Repository, Keychain…, MetadataSyncEngine
│   │       ├── DTOs/
│   │       ├── Mappers/
│   │       └── DataSources/              # framework code
│   │           ├── Local/                # on the device
│   │           │   ├── Persistence/      # SwiftData @Model, SchemaV1…n, migration plan
│   │           │   ├── Capture/          # AVFoundation, hashing, stamping
│   │           │   ├── Reporting/        # PDF + CSV export
│   │           │   ├── Plans/            # PDFKit + CATiledLayer
│   │           │   └── DeviceLink/       # CoreBluetooth
│   │           └── Remote/               # talks to the server
│   │               ├── Networking/       # backend HTTP client
│   │               ├── UploadKit/        # background URLSession engine (standalone)
│   │               └── Realtime/         # WebSocket channel (standalone)
│   ├── Core/                             # Logger/AppLogger, Clock/AppClock + SystemClock; no business logic
│   └── DesignSystem/                     # UI only: never imports Domain or app code
│       ├── Sources/DesignSystem/
│       │   ├── Tokens/                   # DSColor, DSFont, DSSpacing, DSRadius, DSSize
│       │   └── Components/               # DSButtonStyle, DSListRow, DSChip, DSEmptyState…
│       └── Tests/DesignSystemTests/
├── SiteLogTests/                         # app tests; package tests live in each package
│   ├── Presentation/
│   └── Snapshots/
├── SiteLogUITests/
├── Backend/                              # Node + Postgres → 03-backend.md
├── Tools/                                # CI/ Docs/ Hammerspoon/ MockPeripheral/
├── fastlane/  .github/workflows/  Gemfile
├── docs/
│   ├── feature-docs/                     # project specs
│   ├── feature-guide/                    # .md guide per feature (F00–F16)
│   └── design/                           # design plan, mockups, app icon
├── ROADMAP.md
└── project.yml                           # XcodeGen: source of truth for SiteLog.xcodeproj
```

- Dependencies: `App` → every package; `Presentation` → `DomainLayer`, `Core`, `DesignSystem`; `DataLayer` → `DomainLayer` + `Core`; inside `DataLayer`, repositories → `DataSources/Local` and `DataSources/Remote`.
- Layer rules: [00-overview §4](docs/feature-docs/00-overview.md#4-architecture).

</dd></dl>
