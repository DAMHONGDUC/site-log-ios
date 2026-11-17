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
4. [Design](#4-design)

</dd></dl>

## 1. Getting started

<dl><dd>

| Step | Action |
|---|---|
| 1 | `brew install xcodegen swiftlint` |
| 2 | `git submodule update --init` (shared scripts in `Packages/script-tools`) |
| 3 | `xcodegen generate` |
| 4 | Open `SiteLog.xcodeproj`, run the `SiteLog` scheme (⌘R) on an iOS 18.6+ simulator; tests ⌘U |
| 5 | `make` lists the commands; `make reset-xcode` when Xcode gets stuck |
| 6 | Full tooling (VS Code, hot reload, format on save): [05-platform § Dev setup](docs/feature-docs/05-platform.md#dev-setup) |

</dd></dl>

## 2. Docs map

<dl><dd>

| Doc | Contents |
|---|---|
| [ROADMAP.md](docs/ROADMAP.md) | Sprints S0–S9, features F00–F18, steps with hour estimates and ticks |
| [feature-guide/](docs/feature-guide/) | One folder per sprint, one guide per feature: contract → domain → fake data → view models → local → backend → sync → tests |
| [00-overview.md](docs/feature-docs/00-overview.md) | Product, stack, data model, architecture, conventions, decisions D01–D21 |
| [01-field-work.md](docs/feature-docs/01-field-work.md) | 01 Projects · 02 Capture · 03 Issues · 06 DeviceLink · 11 Plans · 12 Annotation · 13 Checklists |
| [02-upload-sync.md](docs/feature-docs/02-upload-sync.md) | 04 Upload engine · 08 Auth and sync · 10 Realtime |
| [03-backend.md](docs/feature-docs/03-backend.md) | 14 Backend API: what the app calls; the server lives in [site-log-be](https://github.com/DAMHONGDUC/site-log-be) |
| [04-reporting-security.md](docs/feature-docs/04-reporting-security.md) | 05 PDF and CSV export · 07 Security and audit log |
| [05-platform.md](docs/feature-docs/05-platform.md) | Dev setup · 09 Diagnostics · Testing · 17 CI/CD · 18 Push and deep links · 19 Instruments |
| [00-design-plan.md](docs/design/00-design-plan.md) | Design principles, tokens, screen inventory; HTML pages and Figma links: [§4 Design](#4-design) |
| [swiftui-rules.md](docs/swiftui-rules.md) | SwiftUI rules: small views, state, design tokens, strings |

- Docs rule: content sits indented under its title. After editing any `.md`, run `python3 Tools/Docs/indent-md.py` (wraps sections in `<dl><dd>`; safe to re-run).

</dd></dl>

## 3. Repo layout

<dl><dd>

- Architecture: Clean Architecture + MVVM; `DomainLayer`, `DataLayer`, `PlatformKit`, `Core`, `DesignSystem` are local Swift packages; the app target holds `App/` and `Presentation/`.
- Target layout: app folders already exist (empty ones hold a `.gitkeep`); package folders arrive with their first file.

```text
site-log-ios/
├── SiteLog/                              # app target: composition root + Presentation
│   ├── App/                              # composition root: may use every layer
│   │   ├── SiteLogApp.swift              # @main
│   │   ├── AppDelegate.swift
│   │   ├── DI/                           # Factory registrations, one file per layer
│   │   ├── Startup/
│   │   │   ├── StartupSequence.swift
│   │   │   └── Steps/                    # Crashlytics, Keychain, ModelContainer, UploadReconcile,
│   │   │                                 # AuditVerify, OrphanSweep
│   │   ├── Config/                       # *.xcconfig, entitlements, GoogleService-Info.plist (CI)
│   │   ├── Fakes/                        # UI skeleton sample data; shrinks as each feature lands
│   │   └── Resources/                    # Assets.xcassets, seeded templates
│   └── Presentation/                     # MVVM: View + ViewModel; 2+ screens → 1 folder / screen
│       ├── Root/  MainTab/  Components/  Navigation/ (coordinator per stack, D19)
│       ├── Resources/Strings/            # Localizable.xcstrings
│       ├── DevMenu/                      # Debug only: reset / seed sample data
│       ├── Access/                       # Splash/ SignIn/ FaceIDLock/ PasscodeUnlock/ PrivacyOverlay/
│       ├── Projects/                     # ProjectList/ NewProject/ ProjectDetail/ Room/ StartSession/
│       │                                 # Survey/ BulkLocations/ CloneTree/ EndSession/
│       ├── Capture/                      # Camera/ CaptureReview/
│       ├── Issues/                       # IssueSheet/ IssueList/ IssueDetail/ VerificationCamera/ OutcomePicker/
│       ├── Annotation/                   # MarkupEditor/ StampPreview/
│       ├── Plans/                        # PlanList/ PlanViewer/ PinPreview/ PlanImport/
│       ├── Checklists/                   # TemplatePicker/ ChecklistRun/ ChecklistDone/
│       ├── Reports/                      # ReportBuilder/ Branding/ SignaturePad/ PDFPreview/
│       ├── Uploads/                      # UploadStatus/ UploadFiles/
│       ├── Diagnostics/                  # DiagnosticExport/
│       ├── Settings/                     # SettingsHome/ Account/ Devices/ AppLock/ SetPasscode/
│       │                                 # StorageCleanup/
│       ├── Notifications/
│       └── DeepLinks/
├── Packages/                             # local Swift packages: Sources/<Name>/ + Tests/<Name>Tests/
│   ├── DomainLayer/                      # Foundation only
│   │   └── Sources/DomainLayer/
│   │       ├── Entities/<Feature>/       # Project, Session, Location, Capture, Issue, Annotation,
│   │       │                             # PlanSheet, PlanPin, ChecklistTemplate/Run/Result
│   │       ├── UseCases/<Feature>/       # <Verb><Noun>UseCase, one per file; DevData/ (Debug reset / seed)
│   │       └── Repositories/             # protocols
│   ├── DataLayer/                        # implements Domain; uses Domain + PlatformKit + Core
│   │   └── Sources/DataLayer/
│   │       ├── Repositories/             # <Noun>RepositoryImpl, SyncEngineImpl
│   │       ├── DataSources/              # protocol + impl each; return models / DTOs, never entities
│   │       │   ├── Local/                # one folder per area: Access/ Biometrics/ Persistence/ (SwiftData)
│   │       │   │                         # Keychain/ FileStorage/ Camera/ Speech/ …
│   │       │   └── Remote/               # <Noun>RemoteDataSource + Impl over PlatformKit engines; Auth/ (Firebase)
│   │       ├── Models/
│   │       │   ├── Local/                # SwiftData @Model: <Noun>Model; Schema/ (SchemaV1…n, migration plan)
│   │       │   └── Remote/               # backend JSON: <Noun>DTO
│   │       └── Mappers/
│   ├── PlatformKit/                      # system services, like an outside library; uses Core only
│   │   └── Sources/PlatformKit/
│   │       ├── Permissions/              # camera, photos, Bluetooth, mic, notifications
│   │       ├── Camera/                   # AVFoundation capture session
│   │       ├── Bluetooth/                # CoreBluetooth (DeviceLink meters)
│   │       ├── Biometrics/               # Face ID (LocalAuthentication)
│   │       ├── Speech/                   # on-device dictation
│   │       ├── Rendering/                # PDF + CSV, PDF / image tiles, stamped copies
│   │       ├── Device/                   # disk, battery, thermal
│   │       ├── Push/                     # APNs registration, FCM token (FirebaseMessaging)
│   │       ├── CrashReporting/           # Crashlytics
│   │       ├── Networking/               # backend HTTP client
│   │       ├── UploadKit/                # background URLSession engine (standalone)
│   │       └── Realtime/                 # WebSocket channel (standalone)
│   ├── Core/                             # Logger/AppLogger, Clock/AppClock + SystemClock, Crypto/ (PasscodeHasher, FileHasher); no business logic
│   ├── DesignSystem/                     # UI only: never imports Domain or app code
│   │   ├── Sources/DesignSystem/
│   │   │   ├── Tokens/                   # DSColor, DSTextStyle, DSSpacing
│   │   │   ├── Components/               # DSButtonStyle, DSListRow, DSChip, DSEmptyState…
│   │   │   └── Modifiers/
│   │   └── Tests/DesignSystemTests/
│   └── script-tools/                     # git submodule: shared shell scripts + make targets (not a Swift package)
├── SiteLogTests/                         # app tests; package tests live in each package
│   └── Presentation/
├── SiteLogUITests/
├── Tools/                                # CI/ Docs/ Hammerspoon/ Xcode/
├── Makefile, script-tools.properties     # make targets from Packages/script-tools/ios/ios.mk
├── fastlane/  .github/workflows/  Gemfile
├── docs/
│   ├── feature-docs/                     # project specs
│   ├── feature-guide/                    # S0–S9 sprint folders, one guide per feature (F00–F18)
│   ├── design/                           # design plan, HTML pages for Figma, app icon
│   ├── images/                           # diagrams used by the docs
│   ├── swiftui-rules.md
│   └── ROADMAP.md                        # sprints, features, ticks
└── project.yml                           # XcodeGen: source of truth for SiteLog.xcodeproj
```

- Dependencies: `App` → every package; `Presentation` → `DomainLayer`, `Core`, `DesignSystem`; `DataLayer` → `DomainLayer` + `PlatformKit` + `Core`; `PlatformKit` → `Core` only, never `DomainLayer`.
- Layer rules: [00-overview §4](docs/feature-docs/00-overview.md#4-architecture).

</dd></dl>

## 4. Design

<dl><dd>

- Figma: [Site Log iOS Design](https://www.figma.com/design/uJZcCP6lzw8QTSkcu8uqvV/Site-Log-iOS-Design) (pages 01–03); pages 04–05 go to a second file, not imported yet ([sync log](docs/design/figma-sync/README.md)).
- HTML pages are the source; open them through the local server, not as files: `python3 -m http.server 8765 --directory docs/design`, then `http://localhost:8765/html/<page>.html`.

| Page | HTML | Figma |
|---|---|---|
| 01 Foundations: app icon, text styles, colours, spacing | [1-foundations.html](docs/design/html/1-foundations.html) | [01 Foundations](https://www.figma.com/design/uJZcCP6lzw8QTSkcu8uqvV/Site-Log-iOS-Design?node-id=0-1) |
| 02 iOS: 69 screens + 3 dark | [2-ios.html](docs/design/html/2-ios.html) | [02 iOS](https://www.figma.com/design/uJZcCP6lzw8QTSkcu8uqvV/Site-Log-iOS-Design?node-id=54-2) |
| 04 Flows: 21 flows on the iOS screens | [4-flows.html](docs/design/html/4-flows.html) | Not imported yet |
| 05 System design: 21 components, iOS and Android | [5-system-design.html](docs/design/html/5-system-design.html) | Not imported yet |

- Plan, principles, screen inventory: [00-design-plan.md](docs/design/00-design-plan.md). Android screens: [3-android.html](docs/design/html/3-android.html), Figma [03 Android](https://www.figma.com/design/uJZcCP6lzw8QTSkcu8uqvV/Site-Log-iOS-Design?node-id=54-3).

</dd></dl>
