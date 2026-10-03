# M2 — Bytes land · TestFlight #1

- M2 — Bytes land · TestFlight #1 · 92h · skeleton guide.

## Contents

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [P19 · UploadKit public API](#p19--uploadkit-public-api)
4. [P20 · Backend skeleton and first migrations](#p20--backend-skeleton-and-first-migrations)
5. [P21 · Presigned upload endpoint](#p21--presigned-upload-endpoint)
6. [P22 · Refresh, complete, abort](#p22--refresh-complete-abort)
7. [P23 · Job model and local store](#p23--job-model-and-local-store)
8. [P24 · Single PUT via background URLSession](#p24--single-put-via-background-urlsession)
9. [P25 · State machine, retry, backoff](#p25--state-machine-retry-backoff)
10. [P26 · Multipart and resume](#p26--multipart-and-resume)
11. [P27 · Kill and relaunch reconciliation](#p27--kill-and-relaunch-reconciliation)
12. [P28 · Wi-Fi only and URL refresh](#p28--wi-fi-only-and-url-refresh)
13. [P29 · S10 upload status screen](#p29--s10-upload-status-screen)
14. [P30 · Sync tab](#p30--sync-tab)
15. [P31 · UploadKit behind the screens](#p31--uploadkit-behind-the-screens)
16. [P32 · Signing and TestFlight #1](#p32--signing-and-testflight-1)
17. [Milestone done](#milestone-done)

## Overview

- **Goal:** move every captured file to R2 through kills, airplane mode and expired URLs; ship TestFlight #1.
- **Demo:** 200 files reach storage and survive app kill and airplane mode.
- **Specs:** [04 Upload engine](../feature-docs/02-upload-sync.md#04-upload-engine), [14 Backend](../feature-docs/03-backend.md#1-role), [17 CI/CD](../feature-docs/05-platform.md#17-cicd-and-testflight)
- **Status:** skeleton — parts, files, order, tests. Full, tested code is added when this milestone starts, built on the real code from the milestone before.

| Part | Track | Hours | Status | What |
|---|---|---|---|---|
| [P19](#p19--uploadkit-public-api) | `Contract` | 3h | not start | UploadKit public API |
| [P20](#p20--backend-skeleton-and-first-migrations) | `Logic` | 6h | not start | Backend skeleton and first migrations |
| [P21](#p21--presigned-upload-endpoint) | `Logic` | 5h | not start | Presigned upload endpoint |
| [P22](#p22--refresh-complete-abort) | `Logic` | 4h | not start | Refresh, complete, abort |
| [P23](#p23--job-model-and-local-store) | `Logic` | 6h | not start | Job model and local store |
| [P24](#p24--single-put-via-background-urlsession) | `Logic` | 10h | not start | Single PUT via background URLSession |
| [P25](#p25--state-machine-retry-backoff) | `Logic` | 6h | not start | State machine, retry, backoff |
| [P26](#p26--multipart-and-resume) | `Logic` | 14h | not start | Multipart and resume |
| [P27](#p27--kill-and-relaunch-reconciliation) | `Logic` | 10h | not start | Kill and relaunch reconciliation |
| [P28](#p28--wi-fi-only-and-url-refresh) | `Logic` | 6h | not start | Wi-Fi only and URL refresh |
| [P29](#p29--s10-upload-status-screen) | `UI` | 5h | not start | S10 upload status screen |
| [P30](#p30--sync-tab) | `UI` | 4h | not start | Sync tab |
| [P31](#p31--uploadkit-behind-the-screens) | `Join` | 3h | not start | UploadKit behind the screens |
| [P32](#p32--signing-and-testflight-1) | `Join` | 10h | not start | Signing and TestFlight #1 |

### Order

- P19 contract first.
- Backend (P20–P22) and UploadKit (P23–P28) in parallel with UI (P29–P30) on the fake store.
- P31 joins; P32 ships TestFlight. P24, P26, P27 are over 8h: split them when you start.

## Target structure

```text
Backend/                      # P20–P22: Node 22 + TypeScript + Fastify, Postgres, migrations/
Packages/
├── UploadKit/                # P19, P23–P28: imports nothing from the project
│   ├── UploadStore.swift, InMemoryUploadStore.swift
│   ├── UploadStateMachine.swift, ChunkPlanner.swift
│   ├── UploadCoordinator.swift (actor), BackgroundSessionDelegate.swift
│   └── PresignedURLProvider.swift
├── Networking/               # P20+: backend HTTP client
└── Persistence/              # P23: SwiftData UploadStore implementation
SiteLog/
├── App/AppDelegate.swift     # P24: handleEventsForBackgroundURLSession
└── Presentation/Uploads/UploadStatus/, SyncTab/     # P29–P30
```

## P19 · UploadKit public API

- **Goal:** job record, states and the `UploadStore` protocol, plus `InMemoryUploadStore`.
- **Spec:** [04.1](../feature-docs/02-upload-sync.md#041-boundary)

| File | Holds |
|---|---|
| `UploadKit/UploadStore.swift` | Protocol from spec 04.1 |
| `UploadKit/UploadJobRecord.swift` | Job, part, state enums |
| `UploadKit/InMemoryUploadStore.swift` | Fake used by tests and the UI track |

### Steps

1. New package; add to `project.yml`.
2. Check `UploadKit` builds alone (CI script from M0 covers it).

### Tests

- Store round-trip on the fake

## P20 · Backend skeleton and first migrations

- **Goal:** Fastify app, Postgres, `0001_uploads.sql`, Firebase token check.
- **Spec:** [14 §2–5](../feature-docs/03-backend.md#2-stack)

| File | Holds |
|---|---|
| `Backend/src/server.ts` | Fastify, `/health`, `requireUser` |
| `Backend/migrations/0001_uploads.sql` | Table from 14 §5.1 |
| `Backend/.env.example` | Every config key; `.env` gitignored |

### Steps

1. Throwaway Postgres for tests (Docker).
2. `vitest` + `tsc` + ESLint in CI (Ubuntu job).

### Tests

- Migrations on empty and seeded DBs
- Expired / revoked token → 401

## P21 · Presigned upload endpoint

- **Goal:** `POST /uploads` returns a single-PUT or multipart plan; keys checked against the caller’s uid.
- **Spec:** [14 §3–4](../feature-docs/03-backend.md#3-endpoints)

| File | Holds |
|---|---|
| `Backend/src/routes/uploads.ts` | Begin, mode by `byteSize` (5 MB threshold, 8 MB parts) |
| `Backend/src/keys.ts` | Strict key regex, no `..` |

### Steps

1. Presign locally with `s3-request-presigner`; TTL 1 h.
2. One R2 bucket per environment.

### Tests

- Key prefix (`other-uid/`, `../`, absolute)
- Mode at 4.9 / 5 / 5.1 MB

## P22 · Refresh, complete, abort

- **Goal:** idempotent `complete`, part URL refresh, abort.
- **Spec:** [14 §7.3](../feature-docs/03-backend.md#73-idempotent-complete)

| File | Holds |
|---|---|
| `Backend/src/routes/uploads.ts` | `/parts/refresh`, `/complete`, `DELETE` |

### Steps

1. `complete` twice → identical 200 body.
2. Never 400 for transient conditions (§10).

### Tests

- Concurrent duplicate complete
- Aborted job cannot complete
- Refresh returns exactly the requested parts

## P23 · Job model and local store

- **Goal:** SwiftData-backed `UploadStore` in `Persistence`.
- **Spec:** [04.1](../feature-docs/02-upload-sync.md#041-boundary)

| File | Holds |
|---|---|
| `Persistence/SwiftDataUploadStore.swift` | Implements `UploadStore` |

### Steps

1. Lookup by `taskDescription = "jobID#part"`.

### Tests

- Same contract tests as the in-memory store

## P24 · Single PUT via background URLSession

- **Goal:** files under 5 MB upload through a background session and survive suspension.
- **Spec:** [04.3](../feature-docs/02-upload-sync.md#043-ios-background-constraints)

| File | Holds |
|---|---|
| `UploadKit/BackgroundSessionDelegate.swift` | Session delegate |
| `UploadKit/UploadCoordinator.swift` | Actor, the only executor of effects |

### Steps

1. `isDiscretionary = false`, `sessionSendsLaunchEvents = true`.
2. Wire `handleEventsForBackgroundURLSession` in AppDelegate.
3. Enqueue the first batch in the foreground.

### Tests

- `MockTransport` flow
- Real device: lock the phone mid-upload

## P25 · State machine, retry, backoff

- **Goal:** pure `UploadStateMachine.reduce` and jittered backoff.
- **Spec:** [04.4](../feature-docs/02-upload-sync.md#044-state-machine)

| File | Holds |
|---|---|
| `UploadKit/UploadStateMachine.swift` | Events → (state, effects); no I/O |

### Steps

1. 401/403 and offline consume no retry budget.
2. Delay `min(2s × 2^n, 300s) × jitter`, max 5 attempts; inject the RNG.

### Tests

- Full (state × event) matrix
- Budget rules
- Backoff with a stubbed RNG

## P26 · Multipart and resume

- **Goal:** files over 5 MB in uniform 8 MB parts, resumable part by part.
- **Spec:** [04.2](../feature-docs/02-upload-sync.md#042-protocol)

| File | Holds |
|---|---|
| `UploadKit/ChunkPlanner.swift` | Fixed-size parts |
| `UploadKit/PartFileWriter.swift` | At most 2 temp part files per job |

### Steps

1. Split this part when you start (planner · upload · complete).
2. Final part failure never calls `complete`.

### Tests

- Planner sizes
- 503 at part 3 retries only part 3

## P27 · Kill and relaunch reconciliation

- **Goal:** cold launch reattaches, cancels or resets jobs so nothing sticks at 60%.
- **Spec:** [04.3](../feature-docs/02-upload-sync.md#043-ios-background-constraints)

| File | Holds |
|---|---|
| `UploadKit/Reconciler.swift` | Three cases: reattach · cancel + log · reset to pending |
| `SiteLog/App/Startup/Steps/ReconcileUploadsStep.swift` | Non-blocking startup step |

### Steps

1. Recreate the session with the same identifier at launch.

### Tests

- All three reconciliation cases
- Real kill on device resumes without re-uploading parts

## P28 · Wi-Fi only and URL refresh

- **Goal:** Wi-Fi-only policy (default on), dedupe by hash, proactive URL refresh.
- **Spec:** [04.5](../feature-docs/02-upload-sync.md#045-policy)

### Steps

1. `allowsCellularAccess = false` when Wi-Fi only.
2. Same `sha256` in a project → reuse `remoteKey`.

### Tests

- 60 s URL TTL refreshes automatically
- Wi-Fi only on cellular sends zero bytes

## P29 · S10 upload status screen

- **Goal:** where-are-my-photos screen on the fake store.
- **Spec:** [09.1](../feature-docs/05-platform.md#091-upload-status-screen)

| File | Holds |
|---|---|
| `Presentation/Uploads/UploadStatus/` | Progress, waiting reasons, failed + Retry |

### Steps

1. “Waiting” uses `DSStatusMarker(.waiting)` — never red.
2. Plain-language reasons, never enum names.

### Tests

- View model
- Snapshots
- Estimates never NaN or negative

## P30 · Sync tab

- **Goal:** queue summary, per-capture upload badge, Wi-Fi-only toggle.

| File | Holds |
|---|---|
| `Presentation/Uploads/SyncTab/` | Replaces the Sync tab placeholder in `MainTabView` |

### Tests

- View model
- Snapshot

## P31 · UploadKit behind the screens

- **Goal:** real `UploadCoordinator` + SwiftData store behind P29–P30; 200-file demo.

| File | Holds |
|---|---|
| `SiteLog/App/AppDependencies.swift` | Swap fake registrations for the real ones |

### Steps

1. Register the real store and coordinator.
2. Run the 200-file demo with a kill in the middle.

### Done when

- 200 files / 2 GB complete with matching server hashes
- Airplane mode → waiting, budget intact

## P32 · Signing and TestFlight #1

- **Goal:** a `v*` tag becomes a TestFlight build with no local step.
- **Spec:** [17](../feature-docs/05-platform.md#17-cicd-and-testflight)

| File | Holds |
|---|---|
| `fastlane/Fastfile` | Lanes `beta`, `release` |
| `.github/workflows/testflight.yml` | Tag `v*`, protected `testflight` environment |

### Steps

1. App Store Connect API key in GitHub secrets (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_CONTENT`).
2. Build number = latest TestFlight + 1.
3. Push `v0.0.1`.

### Done when

- TestFlight build appears; repo holds no `.p8`, certificate or profile

## Milestone done

| Check | How |
|---|---|
| Demo | 200 files survive kill + airplane mode |
| TestFlight #1 | Installed from TestFlight on a real device |
| Roadmap | P19–P32 ticked |
