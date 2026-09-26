# 10 — Realtime progress channel

Module: `Packages/Realtime`

An **observation** channel over a hand-written `URLSessionWebSocketTask`. Complements
[UploadKit](04-upload-engine.md); never controls it.

## 1. Problem it solves

After the final PUT and `complete`, the server assembles parts and verifies checksums. Three cases
where the server knows before the app:

| # | Case | Cost without a channel |
|---|---|---|
| 1 | App killed after `complete`, before the response | Job stays `uploading` until the next reconciliation |
| 2 | Cold launch hours later | 243 individual status requests |
| 3 | Server-side hash mismatch | No path back to the client at all |

## 2. Why WebSocket

| Alternative | Rejected because |
|---|---|
| Polling status | 243 jobs every 10 s burns battery and data on site networks |
| Server-Sent Events | One-way; the client must `subscribe` and heartbeat |
| APNs silent push | Not guaranteed, OS rate-limited, wrong tool |
| **WebSocket** | Bidirectional, one connection, `URLSessionWebSocketTask` |

Transport split: **BLE for control ([06](06-device-link.md)), WebSocket for state, HTTPS for bytes
([04](04-upload-engine.md))**.

## 3. Boundary

**Uploads must work at 100% with the channel dead.**

```
UploadKit  ──(no knowledge of Realtime)──→  runs independently, local store is truth
                                                       ↑
Realtime   ──→ RealtimeEvent ──→ App layer ──→ reconciled into UploadStore
```

- Neither package imports the other; the app layer translates events into `UploadStore` operations.
- Events may only **advance** a job toward `synced`. Server silence never means "not done".
- Disabling the feature flag leaves behavior identical, only slower to learn outcomes.
- Without this boundary, a bug here becomes data loss.

## 4. Protocol

Line-delimited JSON.

| Direction | Messages |
|---|---|
| Client → server | `{type:"auth", token}` · `{type:"subscribe", sessionID}` · `{type:"ping", at}` |
| Server → client | `{type:"jobCompleted", jobID, remoteKey, sha256}` · `{type:"jobFailed", jobID, reason}` · `{type:"snapshot", sessionID, completed[], failed[]}` · `{type:"pong", at}` |

- `snapshot` is the first message after `subscribe` and resolves case 2 in one round trip.
- The token travels in the first `auth` message, **never in a query string** — URLs land in server
  logs, proxy logs, and history. Connection closed if `auth` does not arrive within `authTimeout`.
- Token expiry mid-connection returns close code `4001`; refresh and reconnect, matching the 401
  path in [08](08-auth-sync.md).

Server-side obligations for this protocol: [14-backend.md](14-backend.md).

## 5. Lifecycle

```
disconnected → connecting → authenticating → subscribed
      ↑                                          │
      └────────── backoff ←── failed ←───────────┘
```

Connect only when **all three** hold:

1. The app is in the foreground.
2. At least one job is not `synced`.
3. The current network is permitted (honors the WiFi-only toggle).

Disconnect immediately on backgrounding — iOS closes it anyway, and background state is the
background `URLSession`'s job.

| Mechanism | Detail |
|---|---|
| Ping | `URLSessionWebSocketTask` does not ping itself; cellular NAT drops silently. Ping every `pingInterval`, dead if no `pong` within `pongTimeout` |
| Receive | `receive(completionHandler:)` delivers one message and must be re-armed — forgetting is this API's classic silent bug |
| Reconnect | Independent backoff: base 1 s, cap 60 s, jitter 0.8–1.2, unlimited attempts |
| Resync | Re-subscribe and apply the fresh `snapshot`; never replay missed messages |

```swift
private func listen() {
    task.receive { [weak self] result in
        guard let self else { return }
        switch result {
        case .success(let message):
            Task { await self.handle(message) }
            self.listen()                       // required
        case .failure(let error):
            logger.error("WebSocket receive failed", metadata: [
                "state": "\(self.state)", "error": "\(String(reflecting: error))"
            ])
            Task { await self.scheduleReconnect() }
        }
    }
}
```

## 6. Event handling

| Event | Action |
|---|---|
| `jobCompleted`, local `uploading` or `failed` | → `synced`, store `remoteKey`, delete temp parts |
| `jobCompleted`, already `synced` | Ignore, debug log |
| `jobFailed` `integrity` | → `failed`, red flag in [Diagnostics](09-diagnostics.md), Crashlytics non-fatal |
| `jobFailed` `expired` | → `waitingForURL`, refresh, **no budget consumed** |
| `snapshot` | Diff against `UploadStore`, apply forward transitions only |
| Unknown `jobID` | Ignore and log — may belong to another device on the account |

All mutations go through `UploadStore`; handlers never touch SwiftData directly.

```swift
public enum RealtimeConstants {
    public static let pingInterval: TimeInterval = 30
    public static let pongTimeout: TimeInterval = 10
    public static let authTimeout: TimeInterval = 5
    public static let reconnectBaseDelay: TimeInterval = 1
    public static let reconnectMaxDelay: TimeInterval = 60
    public static let reconnectJitterRange: ClosedRange<Double> = 0.8...1.2
    public static let maxMessageBytes: Int = 64 * 1024
}
```

Messages above `maxMessageBytes` close the connection — never parse arbitrarily sized JSON from the
network.

## 7. Known risks

| Risk | Handling |
|---|---|
| Server reports completion that did not happen | Most serious risk — could lead to deleting un-uploaded files. `jobCompleted` carries `sha256`; the app compares to the local hash before marking `synced`, mismatch is treated as `integrity` |
| Duplicate messages | Handling is idempotent per `jobID` |
| Account switch with the socket open | Close immediately, discard queued messages |
| The channel becoming a dependency | CI job drops `Realtime`; the app must still build and upload |

## 8. Definition of done

- 50 jobs with the socket open reach `synced` via events, no polling.
- Feature flag off → the same 50 jobs still reach `synced`, only slower.
- Two-minute network drop → automatic reconnect, `snapshot` restores correct state.
- `jobCompleted` with a wrong `sha256` does not mark `synced` and raises a flag.
- Backgrounding closes the connection within one second.
- Zero warnings; does not import `UploadKit`.

## 9. Tests

| Test | Kind |
|---|---|
| Event decoding for all 4 types plus malformed payloads | unit, pure |
| Oversized message closes without parsing | unit |
| Missing `pong` → `failed` → backoff | unit, injected clock |
| Backoff respects the cap and applies jitter | unit, injected RNG |
| Mismatched hash does not mark `synced` | unit |
| Applying `jobCompleted` 10 times equals once | unit |
| `snapshot` applies only forward transitions | unit |
| Unknown `jobID` ignored without crashing | unit |
| Full flow against a mock WebSocket server (SwiftNIO) | integration |
| Removing `Realtime` from `Package.swift` still builds | CI |
