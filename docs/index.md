# Documentation index

| Doc | Contents |
|---|---|
| [ROADMAP.md](../ROADMAP.md) | Milestones and ordered parts with hour estimates |
| [adr/](adr/README.md) | Architecture decision records: why each library or hand-written engine was chosen |
| [testing.md](testing.md) | Test layers, tools, rules, coverage targets |
| [design/00-design-plan.md](design/00-design-plan.md) | UI design plan, Figma file, tokens, screen inventory |

## Feature specs

| File | Specs |
|---|---|
| [00-overview.md](feature-docs/00-overview.md) | Product, market, data model, architecture, data flows, infrastructure, conventions |
| [01-field-work.md](feature-docs/01-field-work.md) | 01 Projects, sessions, locations · 02 Capture · 03 Issues and before-after pairing · 06 DeviceLink · 11 Floor plans · 12 Annotation and trusted time · 13 Checklists |
| [02-upload-sync.md](feature-docs/02-upload-sync.md) | 04 Upload engine · 08 Auth and sync · 10 Realtime channel |
| [03-backend.md](feature-docs/03-backend.md) | 14 Backend (Node, Postgres, sync, WebSocket) |
| [04-reporting-security.md](feature-docs/04-reporting-security.md) | 05 PDF and spreadsheet export · 07 Security and audit log |
| [05-platform.md](feature-docs/05-platform.md) | 09 Diagnostics · 17 CI/CD and TestFlight · 18 Push and deep links · 19 Instruments |

## Developer tooling

| Doc | Contents |
|---|---|
| [xcode-format-on-save.md](dev-docs/xcode-format-on-save.md) | Auto-run `swift-format` on ⌘S in Xcode via Hammerspoon |
| [swiftlint.md](dev-docs/swiftlint.md) | SwiftLint build phase, rules, split with `swift-format` |
| [xcodegen.md](dev-docs/xcodegen.md) | `project.yml` is the source of truth for `SiteLog.xcodeproj` |
| [hot-reload.md](dev-docs/hot-reload.md) | Hot reload in the simulator with Inject + InjectionNext |
| [code-snippets.md](dev-docs/code-snippets.md) | Xcode snippets `view` / `viewvm` for new screens |
