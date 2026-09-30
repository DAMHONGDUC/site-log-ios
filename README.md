# SiteLog

| | |
|---|---|
| Overview | Offline-first iOS app for site supervisors to record construction site conditions and export a signed PDF inspection report |
| Last edit | 2026-09-30 |
| Author | Dam Hong Duc |
| Docs | [docs/index.md](docs/index.md) · build order in [ROADMAP.md](ROADMAP.md) |

## Store links

| Platform | Link |
|---|---|
| App Store | Not published |

## App IDs

| ID | Value |
|---|---|
| iOS bundle ID | `app.dd.site.log` |

## Tech stack

| Category | Technology | Version |
|---|---|---|
| Framework | SwiftUI | iOS 18.6 deployment target |
| Language | Swift | 6 (strict concurrency) |
| State management | Observation (`@Observable` view models, planned); `@State` in current code | iOS 17+ API |
| Backend | Node.js, TypeScript, Fastify, PostgreSQL (planned, not in repo yet) | Node 22, PostgreSQL 16 |
| Local DB | SwiftData (planned, not in repo yet) | iOS 18 |
| Special libraries | Inject (hot reload, Debug only) | 1.6.0 |

## Project architecture

| | |
|---|---|
| Architecture | Clean Architecture (Presentation · Domain · Data), MVVM in Presentation, SPM packages per layer |
| Encryption | Planned: Data Protection `.completeUnlessOpen` for media, AES-GCM for export bundles, HMAC-SHA256 audit chain, Keychain for keys and tokens |

Only `Packages/Core` exists today; the rest is specified in [00-project-info.md](docs/feature-docs/00-project-info.md) §4.

```mermaid
flowchart TD
  subgraph Presentation
    View["Views (SwiftUI)"] --> VM["ViewModels (@Observable)"]
  end
  subgraph Domain["Domain · Packages/Core"]
    UC["Use cases"] --> RP["Repository protocols"]
    UC --> ENT["Entities"]
  end
  subgraph Data["Data · Packages/Data"]
    RI["Repository impls, DTOs, mappers"]
  end
  subgraph Sources["Data sources"]
    SD["Persistence (SwiftData)"]
    NET["Networking"]
    FW["Capture · UploadKit · Reporting · Plans · DeviceLink · Realtime"]
  end
  VM --> UC
  RI -. implements .-> RP
  RI --> SD
  RI --> NET
  RI --> FW
  NET --> BE["Backend (Fastify + PostgreSQL)"]
  FW --> R2[("Cloudflare R2")]
```

## Local database

Planned SwiftData schema from [00-project-info.md](docs/feature-docs/00-project-info.md) §3.

```mermaid
erDiagram
  Project ||--o{ Session : has
  Project ||--o{ Location : has
  Project ||--o{ PlanSheet : has
  Project ||--o{ ChecklistTemplate : has
  Location ||--o{ Location : parent
  Location ||--o{ Capture : has
  Location ||--o{ Issue : anchors
  Location ||--o{ ChecklistRun : has
  Session ||--o{ Capture : contains
  Capture ||--o{ Annotation : has
  Issue }o--o{ Capture : evidence
  Issue ||--o| PlanPin : pinned
  PlanSheet ||--o{ PlanPin : has
  ChecklistTemplate ||--o{ ChecklistRun : instantiates
  ChecklistRun ||--o{ ChecklistResult : has

  Project {
    uuid id
    string name
  }
  Session {
    uuid id
    string state
  }
  Location {
    uuid id
    string code
    string kind
  }
  Capture {
    uuid id
    string sha256
    string uploadState
  }
  Annotation {
    uuid id
    json shapes
  }
  Issue {
    uuid id
    string severity
    string status
  }
  PlanSheet {
    uuid id
    string sha256
  }
  PlanPin {
    uuid id
    float x
    float y
  }
  ChecklistTemplate {
    uuid id
    string name
  }
  ChecklistRun {
    uuid id
    date startedAt
  }
  ChecklistResult {
    uuid id
    string outcome
  }
```
