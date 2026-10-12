# F13 — Realtime progress and verification

<dl><dd>

- F13 · 20h · skeleton guide — full code is added when this feature starts.

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Fake data — Fake event stream](#1-fake-data--fake-event-stream)
4. [2. View models — Live state on the Sync tab](#2-view-models--live-state-on-the-sync-tab)
5. [3. Real data — Channel, bridge, verification worker](#3-real-data--channel-bridge-verification-worker)
6. [Tests (after the feature works)](#tests-after-the-feature-works)
7. [Feature done](#feature-done)

</dd></dl>

## Overview

<dl><dd>

- **Goal:** Realtime progress and verification end to end: Domain → fake data → view models → real data → tests.
- **Demo:** the Sync tab shows server-confirmed state as events arrive; mismatches are flagged.
- **Spec:** [10](../feature-docs/02-upload-sync.md#10-realtime-progress-channel), [14 §8–9](../feature-docs/03-backend.md#8-integrity)
- **Starts from:** the skeleton screens (~30% of Figma) that read `App/Fakes/FakeData.swift`.
- **Fakes:** only in `Packages/DataLayer/Sources/DataLayer/Fakes/`, registered in `AppDependencies`; the dev menu seeds / clears them through `FakeDevDataActions`.
- **File tags:** <b class="tag-new">New</b> create the file.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-fake-data--fake-event-stream) | Fake data | 1h | not start | Fake event stream |
| [2](#2-view-models--live-state-on-the-sync-tab) | View models | 2h | not start | Live state on the Sync tab |
| [3](#3-real-data--channel-bridge-verification-worker) | Real data | 17h | not start | Channel, bridge, verification worker |

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
Backend/src/ws.ts, workers/verify.ts     # 3
Packages/
├── DataLayer/Sources/DataLayer/Fakes/FakeRealtimeChannel.swift  # 1: scripted events
└── DataLayer/Sources/DataLayer/DataSources/Remote/Realtime/     # 3: RealtimeChannel (actor), messages
SiteLog/
├── App/RealtimeBridge.swift                                     # 3
└── Presentation/Uploads/UploadStatus/                           # 2: live state
```

</dd></dl>

## 1. Fake data — Fake event stream

<dl><dd>

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Packages/DataLayer/Sources/DataLayer/Fakes/FakeRealtimeChannel.swift` | Emits `jobCompleted` / `jobFailed` on a timer |

</dd></dl>

## 2. View models — Live state on the Sync tab

<dl><dd>

- **Goal:** S10 shows server-confirmed state as events arrive.
- **Spec:** [09.1](../feature-docs/05-platform.md#091-upload-status-screen)

#### Steps

<dl><dd>

1. A closed channel is not an error, only slower — no red.

</dd></dl>

</dd></dl>

## 3. Real data — Channel, bridge, verification worker

<dl><dd>

<details open>
<summary><strong>3.1 Realtime client</strong></summary>
<dl><dd>

- **Goal:** observation-only WebSocket: connect, auth in the first message, ping, reconnect with backoff.
- **Spec:** [10](../feature-docs/02-upload-sync.md#10-realtime-progress-channel)

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Packages/DataLayer/Sources/DataLayer/DataSources/Remote/Realtime/RealtimeChannel.swift` | Actor around `URLSessionWebSocketTask` |
| <b class="tag-new">New</b> | `Packages/DataLayer/Sources/DataLayer/DataSources/Remote/Realtime/Messages.swift` | `auth`, `subscribe`, `ping` / `snapshot`, `jobCompleted`, `jobFailed`, `pong` |
| <b class="tag-new">New</b> | `Backend/src/ws.ts` | Server side per 14 §9 |

#### Steps

<dl><dd>

1. Token in the first `auth` message, never the URL.
2. Re-arm `receive` after every message.
3. Connect only in foreground with unsynced jobs.

</dd></dl>
</details>

<details open>
<summary><strong>3.2 Events into the upload store</strong></summary>
<dl><dd>

- **Goal:** the app layer turns events into `UploadStore` operations that only move jobs forward.
- **Spec:** [10](../feature-docs/02-upload-sync.md#10-realtime-progress-channel)

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `SiteLog/App/RealtimeBridge.swift` | Composition root: Realtime → UploadStore |

</dd></dl>

#### Steps

<dl><dd>

1. `jobCompleted` trusted only if its `sha256` matches the local hash.
2. Unknown `jobID` ignored; handling idempotent.
3. Nightly CI builds the app with `Realtime` removed.

</dd></dl>
</details>

<details open>
<summary><strong>3.3 Verification worker</strong></summary>
<dl><dd>

- **Goal:** backend re-reads each object from R2 and flips `registered` → `verified` or `mismatch`.
- **Spec:** [14 §8](../feature-docs/03-backend.md#8-integrity)

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Backend/src/workers/verify.ts` | Streams the object, recomputes SHA-256 |
| <b class="tag-new">New</b> | `Backend/src/jobs/abandoned.ts` | Aborts `created` uploads older than 7 days |

</dd></dl>

#### Steps

<dl><dd>

1. Mismatch pushes `jobFailed(integrity)` to the app.
2. The report prints exactly the state reached.

</dd></dl>
</details>

</dd></dl>

</dd></dl>

## Tests (after the feature works)

<dl><dd>

**2. View models — Live state on the Sync tab**

- View model with a fake event stream

**3. Real data — Channel, bridge, verification worker**

- Decode all types + malformed
- Oversized message closes
- Missing `pong` → backoff
- Backoff cap and jitter
- Applying one event 10× equals once
- Snapshot applies forward only
- Hash mismatch raises `integrity`
- Worker flips `verified` or raises `integrity`
- `/verify` shows the new state

</dd></dl>

## Feature done

<dl><dd>

| Check | How |
|---|---|
| Demo | Realtime state on the Sync tab |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F13 steps ticked |

</dd></dl>
