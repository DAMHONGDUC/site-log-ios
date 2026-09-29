# SiteLog

Offline-first iOS app for recording construction site conditions. The deliverable is a signed PDF
inspection report with a verifiable chain of custody for every photo.

```
Create project → start survey session → walk floors and rooms, capture and log defects
→ reach WiFi, background upload → export a signed PDF report
```

Users: site supervisors, subcontractors, and apartment handover teams.

## Why it is built this way

Sites, basements, and alleys have weak signal or none. One survey produces **150–250 files and
several GB**. The user closes the app, pockets the phone, and keeps walking.

Every competitor in this category loses evidence the same three ways: uploads stall or complete
with photos missing, photos vanish on reload, and sync fails with nothing the user can act on.
SiteLog assumes the network is bad and is built around that assumption rather than against it.

| Constraint | Consequence |
|---|---|
| No signal for hours | Every write path completes offline |
| Multi-GB sessions | Transfers survive suspension, termination, and network loss |
| App killed in a pocket | No state lives only in RAM |
| The PDF is the paid deliverable | Never truncated, never silently missing an image |

## Architecture

```mermaid
flowchart LR
    App["iOS app<br/>SwiftUI · SwiftData"]
    BE["Backend<br/>Fastify + Postgres"]
    R2[("Cloudflare R2")]
    FB["Firebase Auth"]

    App -->|"sign · complete · refresh"| BE
    App -->|"PUT bytes, presigned URL"| R2
    BE -->|"progress over WebSocket"| App
    BE -->|"verify token"| FB
    BE -.->|"read back to verify hash"| R2
```

Control, bytes, and state travel on three separate paths. The backend never sits in the data path,
so a slow backend cannot stall an upload.

## Hand-written on purpose

No SDK stands in for the parts that matter. Each of these is a deliberate trade of development
speed for depth:

| Component | Instead of | Why |
|---|---|---|
| **Upload engine** — background `URLSession`, S3 multipart, resume, retry | Firebase Storage `putFile()` | Cannot reattach to in-flight uploads after a cold launch, cannot control `isDiscretionary` or priority |
| **Capture pipeline** — `AVCaptureSession` + `AVAssetWriter`, streaming SHA-256 | `PhotosPicker` | A hash only means something for a file the app produced |
| **Sync engine** — revision cursors, tombstones, offline mutation queue | Firestore | Full control over conflict rules and delete propagation |
| **DeviceLink** — CoreBluetooth profiles for laser and moisture meters | Manual retyping | BLE for control and small values, WiFi for large files |

The upload state machine is pure and synchronous, so kill-mid-flight, expired presigned URLs, and a
failing final part are all testable without a network.

## Chain of custody

- `Capture` is immutable after creation; `sha256` is computed before the database write.
- Annotations are a separate vector layer, so marking up a photo never invalidates its hash.
- Every capture records clock provenance with a confidence level, because a device clock is
  user-settable.
- The report prints what actually happened — `registered` when the server recorded a hash,
  `verified` only after a worker read the object back and recomputed it.

## Stack

| Area | Choice |
|---|---|
| App | SwiftUI, SwiftData, Swift Concurrency, SPM modules · iOS 18+ |
| Media | AVFoundation, PDFKit, CryptoKit |
| Backend | Node 22, TypeScript, Fastify, PostgreSQL, raw SQL |
| Storage | Cloudflare R2, S3 multipart with presigned URLs |
| Identity | Firebase Auth and Crashlytics only |

## Documentation

Sixteen specifications covering product, market, architecture, data flows, every feature, the
backend contract, and a twelve-week plan. Start at [00-project-info.md](docs/feature-docs/00-project-info.md).

| # | Document | Contents |
|---|---|---|
| 00 | [00-project-info.md](docs/feature-docs/00-project-info.md) | Product, market, data model, architecture, data flows, CI, conventions |
| 01 | [01-project-session.md](docs/feature-docs/01-project-session.md) | Projects, sessions, locations |
| 02 | [02-capture.md](docs/feature-docs/02-capture.md) | Capture pipeline |
| 03 | [03-issue-tracking.md](docs/feature-docs/03-issue-tracking.md) | Issue tracking & before/after pairing |
| 04 | [04-upload-engine.md](docs/feature-docs/04-upload-engine.md) | Upload engine |
| 05 | [05-reporting.md](docs/feature-docs/05-reporting.md) | PDF & spreadsheet export |
| 06 | [06-device-link.md](docs/feature-docs/06-device-link.md) | DeviceLink: BLE measuring tools |
| 07 | [07-security.md](docs/feature-docs/07-security.md) | Security & audit log |
| 08 | [08-auth-sync.md](docs/feature-docs/08-auth-sync.md) | Auth & sync |
| 09 | [09-diagnostics.md](docs/feature-docs/09-diagnostics.md) | Diagnostics & observability |
| 10 | [10-realtime-progress.md](docs/feature-docs/10-realtime-progress.md) | Realtime progress channel |
| 11 | [11-floorplan-pins.md](docs/feature-docs/11-floorplan-pins.md) | Floor plans & issue pins |
| 12 | [12-annotation.md](docs/feature-docs/12-annotation.md) | Annotation & verifiable stamps |
| 13 | [13-checklists.md](docs/feature-docs/13-checklists.md) | Checklist templates |
| 14 | [14-backend.md](docs/feature-docs/14-backend.md) | Backend (Node.js) |
| 15 | [15-roadmap.md](docs/feature-docs/15-roadmap.md) | Roadmap & Trello task board |
| 16 | [16-learning-swiftui.md](docs/feature-docs/16-learning-swiftui.md) | Swift & SwiftUI learning plan |

Developer tooling and workflow setup notes (editor config, local scripts, environment setup) live
separately in `docs/dev-docs/`:

| Document | Contents |
|---|---|
| [xcode-format-on-save.md](docs/dev-docs/xcode-format-on-save.md) | Auto-run `swift-format` on ⌘S in Xcode via Hammerspoon |
| [swiftlint.md](docs/dev-docs/swiftlint.md) | SwiftLint build phase, rules, and split with `swift-format` |

## Status

Specifications complete. Implementation starts at week 1; see
[docs/feature-docs/15-roadmap.md](docs/feature-docs/15-roadmap.md) for milestones and the task board.
