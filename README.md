# SiteLog

- Offline-first iOS app for site supervisors: record construction site conditions, export a signed
  PDF inspection report.
- Author: Dam Hong Duc · bundle ID `app.dd.site.log` · App Store: not published.

## Contents

1. [Getting started](#1-getting-started)
2. [Docs map](#2-docs-map)
3. [Repo layout](#3-repo-layout)

## 1. Getting started

| Step | Action |
|---|---|
| 1 | `brew install xcodegen swiftlint` |
| 2 | `xcodegen generate` |
| 3 | Open `SiteLog.xcodeproj`, run the `SiteLog` scheme (⌘R) on an iOS 18.6+ simulator; tests ⌘U |
| 4 | Full tooling (VS Code, hot reload, format on save): [05-platform § Dev setup](docs/feature-docs/05-platform.md#dev-setup) |

## 2. Docs map

| Doc | Contents |
|---|---|
| [ROADMAP.md](ROADMAP.md) | Milestones M0–M6, parts on UI / Logic tracks, hour estimates |
| [milestone-guide/](docs/milestone-guide/) | One guide per milestone (M0–M6): every part, step by step |
| [00-overview.md](docs/feature-docs/00-overview.md) | Product, stack, data model, architecture, conventions, decisions D01–D08 |
| [01-field-work.md](docs/feature-docs/01-field-work.md) | 01 Projects · 02 Capture · 03 Issues · 06 DeviceLink · 11 Plans · 12 Annotation · 13 Checklists |
| [02-upload-sync.md](docs/feature-docs/02-upload-sync.md) | 04 Upload engine · 08 Auth and sync · 10 Realtime |
| [03-backend.md](docs/feature-docs/03-backend.md) | 14 Backend: Node, Postgres, sync, WebSocket |
| [04-reporting-security.md](docs/feature-docs/04-reporting-security.md) | 05 PDF and CSV export · 07 Security and audit log |
| [05-platform.md](docs/feature-docs/05-platform.md) | Dev setup · 09 Diagnostics · Testing · 17 CI/CD · 18 Push and deep links · 19 Instruments |
| [00-design-plan.md](docs/design/00-design-plan.md) | Design principles, tokens, screen inventory; [mockups](docs/design/mockups/index.html) |

## 3. Repo layout

```
site-log-ios/
├── SiteLog/              # app: composition root (App/) + Presentation (MVVM) + Helper + Resources
├── Packages/             # Domain, DataLayer, DesignSystem (+ data sources as milestones start)
├── SiteLogTests/ SiteLogUITests/
├── Tools/                # CI scripts, Hammerspoon config
├── docs/
│   ├── feature-docs/     # project specs
│   ├── milestone-guide/  # .md guide per milestone (M0–M6)
│   └── design/           # design plan, mockups, app icon
├── ROADMAP.md
└── project.yml           # XcodeGen: source of truth for SiteLog.xcodeproj
```

- Full layout and layer rules: [00-overview §4](docs/feature-docs/00-overview.md#4-architecture).
