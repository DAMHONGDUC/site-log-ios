# M6 — Polish

- M6 — Polish · 50h · skeleton guide.

## Contents

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [P71 · Realtime client](#p71--realtime-client)
4. [P72 · Events into the upload store](#p72--events-into-the-upload-store)
5. [P73 · Verification worker](#p73--verification-worker)
6. [P74 · Push notifications](#p74--push-notifications)
7. [P75 · Deep links](#p75--deep-links)
8. [P76 · Live state on the upload screen](#p76--live-state-on-the-upload-screen)
9. [P77 · Notification permission and settings](#p77--notification-permission-and-settings)
10. [P78 · Accessibility pass](#p78--accessibility-pass)
11. [P79 · Budgets, feedback, submission prep](#p79--budgets-feedback-submission-prep)
12. [Milestone done](#milestone-done)

## Overview

- **Goal:** realtime job state, server-side verification, push, deep links, accessibility; ready for App Store submission.
- **Demo:** realtime state, push, deep links, accessibility, ready for submission.
- **Specs:** [10 Realtime](../feature-docs/02-upload-sync.md#10-realtime-progress-channel), [14 §8–9](../feature-docs/03-backend.md#8-integrity), [18 Push and deep links](../feature-docs/05-platform.md#18-push-notifications-and-deep-links), [19 Instruments](../feature-docs/05-platform.md#19-performance-profiling-with-instruments)
- **Status:** skeleton — parts, files, order, tests. Full, tested code is added when this milestone starts, built on the real code from the milestone before.

| Part | Track | Hours | Status | What |
|---|---|---|---|---|
| [P71](#p71--realtime-client) | `Logic` | 6h | not start | Realtime client |
| [P72](#p72--events-into-the-upload-store) | `Logic` | 6h | not start | Events into the upload store |
| [P73](#p73--verification-worker) | `Logic` | 6h | not start | Verification worker |
| [P74](#p74--push-notifications) | `Logic` | 6h | not start | Push notifications |
| [P75](#p75--deep-links) | `Logic` | 3h | not start | Deep links |
| [P76](#p76--live-state-on-the-upload-screen) | `UI` | 3h | not start | Live state on the upload screen |
| [P77](#p77--notification-permission-and-settings) | `UI` | 2h | not start | Notification permission and settings |
| [P78](#p78--accessibility-pass) | `UI` | 8h | not start | Accessibility pass |
| [P79](#p79--budgets-feedback-submission-prep) | `Join` | 10h | not start | Budgets, feedback, submission prep |

### Order

- No contract part: M6 extends existing protocols (`UploadStore`, `DeepLink`).
- P71 needs M5 (auth + sync). Logic P71–P75 and UI P76–P78 in parallel.
- P79 closes the milestone and prepares submission. P79 is over 8h: split it.

## Target structure

```text
SiteLog/
├── DataSources/Realtime/     # P71–P72: RealtimeChannel (actor), messages, uses nothing from the rest of the app
└── Domain/DeepLinks/         # P75: DeepLink type + pure parser
Backend/src/
├── ws.ts                     # P71: /ws, auth, snapshot, pg_notify fan-out
└── workers/verify.ts         # P73: re-hash objects from R2
SiteLog/
├── App/AppDelegate.swift     # P74: push token, remote-notification handling
└── Presentation/
    ├── Notifications/        # P74, P77
    ├── DeepLinks/            # P75: router that holds the destination until consumed
    └── Uploads/UploadStatus/ # P76: live server state
```

## P71 · Realtime client

- **Goal:** observation-only WebSocket: connect, auth in the first message, ping, reconnect with backoff.
- **Spec:** [10](../feature-docs/02-upload-sync.md#10-realtime-progress-channel)

| File | Holds |
|---|---|
| `SiteLog/DataSources/Realtime/RealtimeChannel.swift` | Actor around `URLSessionWebSocketTask` |
| `SiteLog/DataSources/Realtime/Messages.swift` | `auth`, `subscribe`, `ping` / `snapshot`, `jobCompleted`, `jobFailed`, `pong` |
| `Backend/src/ws.ts` | Server side per 14 §9 |

### Steps

1. Token in the first `auth` message, never the URL.
2. Re-arm `receive` after every message.
3. Connect only in foreground with unsynced jobs.

### Tests

- Decode all types + malformed
- Oversized message closes
- Missing `pong` → backoff
- Backoff cap and jitter

## P72 · Events into the upload store

- **Goal:** the app layer turns events into `UploadStore` operations that only move jobs forward.
- **Spec:** [10](../feature-docs/02-upload-sync.md#10-realtime-progress-channel)

| File | Holds |
|---|---|
| `SiteLog/App/RealtimeBridge.swift` | Composition root: Realtime → UploadStore |

### Steps

1. `jobCompleted` trusted only if its `sha256` matches the local hash.
2. Unknown `jobID` ignored; handling idempotent.
3. Nightly CI builds the app with `Realtime` removed.

### Tests

- Applying one event 10× equals once
- Snapshot applies forward only
- Hash mismatch raises `integrity`

## P73 · Verification worker

- **Goal:** backend re-reads each object from R2 and flips `registered` → `verified` or `mismatch`.
- **Spec:** [14 §8](../feature-docs/03-backend.md#8-integrity)

| File | Holds |
|---|---|
| `Backend/src/workers/verify.ts` | Streams the object, recomputes SHA-256 |
| `Backend/src/jobs/abandoned.ts` | Aborts `created` uploads older than 7 days |

### Steps

1. Mismatch pushes `jobFailed(integrity)` to the app.
2. The report prints exactly the state reached.

### Tests

- Worker flips `verified` or raises `integrity`
- `/verify` shows the new state

## P74 · Push notifications

- **Goal:** push that carries a destination only; works fully when denied.
- **Spec:** [18](../feature-docs/05-platform.md#18-push-notifications-and-deep-links)

| File | Holds |
|---|---|
| `project.yml` | Push capability, `aps-environment`, `remote-notification` background mode |
| `SiteLog/App/AppDelegate.swift` | Token registration (logged truncated), re-sent on change |

### Steps

1. Ask for permission at a moment that makes sense, not at first launch.
2. Test: `xcrun simctl push booted app.dd.site.log payload.json`.

### Tests

- Payload with / without `deepLink`
- Push for another account ignored

## P75 · Deep links

- **Goal:** `sitelog://<route>/<id>` parsed once, routed after cold launch.
- **Spec:** [18](../feature-docs/05-platform.md#18-push-notifications-and-deep-links)

| File | Holds |
|---|---|
| `Domain/DeepLinks/DeepLink.swift` | Pure parser; ids are opaque data |
| `Presentation/DeepLinks/DeepLinkRouter.swift` | Holds the destination until a view consumes it |

### Steps

1. Add the `sitelog` URL scheme in `project.yml`.
2. Deleted target lands on a safe screen.
3. Test: `xcrun simctl openurl booted sitelog://session/42`.

### Tests

- Parser routes and rejections
- Router holds until consumed
- Cold-launch link survives (UI test)

## P76 · Live state on the upload screen

- **Goal:** S10 shows server-confirmed state as events arrive.
- **Spec:** [09.1](../feature-docs/05-platform.md#091-upload-status-screen)

### Steps

1. A closed channel is not an error, only slower — no red.

### Tests

- View model with a fake event stream
- Snapshot

## P77 · Notification permission and settings

- **Goal:** permission prompt at the right moment; notification row in Settings.

### Steps

1. Explain the benefit before the system prompt.

### Tests

- View model
- Snapshot

## P78 · Accessibility pass

- **Goal:** every screen readable with Dynamic Type, VoiceOver and high contrast.

| File | Holds |
|---|---|
| Every screen | Labels, traits, grouping, focus order |
| `SiteLogTests/Snapshots/` | `accessibility3` snapshot per screen |

### Steps

1. VoiceOver walk: unlock → projects → capture → report.
2. Severity readable without colour (shapes already in `DSStatusMarker`).
3. Minimum 44 pt targets.

### Tests

- Snapshots at `accessibility3`
- Xcode Accessibility Inspector audit clean

## P79 · Budgets, feedback, submission prep

- **Goal:** Instruments budgets met, TestFlight feedback closed, App Store submission ready.
- **Spec:** [19](../feature-docs/05-platform.md#19-performance-profiling-with-instruments)

| File | Holds |
|---|---|
| `fastlane/Fastfile` | `release` lane waits for processing |
| `SiteLog/PrivacyInfo.xcprivacy` | Location, device ID, crash data declared |

### Steps

1. Split when you start (Instruments · feedback · submission).
2. Run scenarios 1–5 of 05 §19 on device, Release build; save traces.
3. Store listing, screenshots, privacy answers; submission stays manual.

### Done when

- Every budget met with a recorded trace
- No open TestFlight feedback
- Build submitted for review

## Milestone done

| Check | How |
|---|---|
| Demo | Realtime state, push opens the target, deep link from Safari, VoiceOver walk |
| Release | App Store submission sent |
| Roadmap | P71–P79 ticked |
