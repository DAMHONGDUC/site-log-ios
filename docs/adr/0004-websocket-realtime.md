# 0004 — WebSocket realtime channel

Status: Accepted · 2026-09-30 · Spec: [10](../feature-docs/02-upload-sync.md#10-realtime-progress-channel)

## Context

The server learns about completed assembly, checksum results and hash mismatches before the app
does, especially after the app was killed mid-upload.

## Decision

An observation-only channel on `URLSessionWebSocketTask` in `Packages/Realtime`: connect, auth with
the Firebase ID token, ping, reconnect with backoff, events reconciled into the upload store. It never
controls `UploadKit`.

## Rejected

| Option | Why not |
|---|---|
| Polling | 243 jobs every 10 s drains battery and data on site networks |
| Server-Sent Events | One-way; subscribe and heartbeat still need a second path |
| APNs silent push | Not guaranteed, rate-limited |
| Starscream / Socket.IO | `URLSessionWebSocketTask` covers the protocol; no extra dependency needed |

## Consequences

- The app must build and pass tests with `Realtime` removed (nightly CI check).
- Backend serves the channel from the same process, fanned out by `pg_notify`.
