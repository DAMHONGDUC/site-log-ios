# Upload and sync

<dl><dd>

- How bytes and metadata leave the device and reach other devices. Server side: [03-backend.md](03-backend.md).

| Path | Carries | Spec |
|---|---|---|
| HTTPS presigned PUT | Bytes | [04](#04-upload-engine) |
| Delta sync | Metadata | [08](#08-auth-and-sync) |
| WebSocket | Server-side job state | [10](#10-realtime-progress-channel) |
| BLE | Measuring tools only | [06](01-field-work.md#06-devicelink-ble-measuring-tools) |

</dd></dl>

## Contents

<dl><dd>

- [04 Upload engine](#04-upload-engine) — boundary, protocol, background constraints, state machine, policy
- [08 Auth and sync](#08-auth-and-sync) — offline-first and auth, protocol, client engine
- [10 Realtime progress channel](#10-realtime-progress-channel)

---

</dd></dl>

## 04. Upload engine

<dl><dd>

- Module: `Packages/DataLayer/Sources/DataLayer/DataSources/Remote/UploadKit` — standalone, uses nothing else from SiteLog ([D02](00-overview.md#d02--hand-written-upload-engine))

**Goal:** move 150–250 files and several GB to R2, surviving network loss, suspension, termination,
reboot and presigned-URL expiry.

### 04.1 Boundary

<dl><dd>

- In: a file URL, metadata, an endpoint, an injected store. Does not import `DomainLayer`.

```swift
public protocol UploadStore: Sendable {
    func upsert(_ job: UploadJobRecord) async throws
    func job(id: UploadJobID) async throws -> UploadJobRecord?
    func job(forTaskDescription key: String) async throws -> UploadJobRecord?
    func pendingJobs(limit: Int) async throws -> [UploadJobRecord]
    func updatePart(_ part: UploadPartRecord) async throws
    func delete(id: UploadJobID) async throws
}
```

- The app implements it over SwiftData in `Persistence`.
- `UploadKit` ships `InMemoryUploadStore`: the state machine is testable with no app, DB or network.
- Files: `UploadCoordinator` (actor, entry point), `UploadStateMachine` (pure), `ChunkPlanner`,
  `PresignedURLProvider`, `BackgroundSessionDelegate`.

</dd></dl>

### 04.2 Protocol

<dl><dd>

- The backend never touches bytes. Endpoints: [03-backend.md §3](03-backend.md#3-endpoints).

| Step | Call | Returns |
|---|---|---|
| 1 | `POST /uploads {key, byteSize, contentType, sha256}` | `single {uploadId, url}` or `multipart {uploadId, partSizeBytes, parts[]}` |
| 2 | `PUT <presigned url>` (part temp file) | 200 + ETag |
| 3 | `POST /uploads/:id/complete {parts[{number, etag}]}` | `{remoteKey, verificationCode, verified}` — idempotent |
| 4 | `POST /uploads/:id/parts/refresh {numbers}` | Fresh URLs — **mandatory** after a long kill |
| 5 | `DELETE /uploads/:id` | Abort |

- Mode from `byteSize`: under 5 MB single PUT, else multipart with uniform 8 MB parts (R2 requires
  equal non-final parts, so `ChunkPlanner` splits by fixed size).
- Every call carries a Firebase ID token; the key prefix must match its uid.

</dd></dl>

### 04.3 iOS background constraints

<dl><dd>

| Constraint | Consequence |
|---|---|
| Background sessions accept only `uploadTask(with:fromFile:)` | Each part written to a temp file; at most `maxMaterializedPartsPerJob` ahead; deleted on 200 + ETag |
| Tasks created while backgrounded are discretionary | Enqueue the first batch in the foreground; say "will upload when idle" |
| `taskIdentifier` is reused | Key on `taskDescription = "jobID#part"` |
| Nothing survives termination in RAM | Recreate the session with the same identifier and reconcile |

- Session: `isDiscretionary = false`, `sessionSendsLaunchEvents = true`, resource timeout 7 days,
  `handleEventsForBackgroundURLSession` wired in the app delegate.

**Cold-launch reconciliation** (the usual cause of "stuck at 60%"):

| Task | Record | Action |
|---|---|---|
| Alive | Exists | Reattach |
| Alive | Missing | Cancel and log |
| Missing | `uploading` | Reset to `pending` |

- A [realtime](#10-realtime-progress-channel) `snapshot` adds server state; jobs only move forward.

</dd></dl>

### 04.4 State machine

<dl><dd>

```
pending → planning → uploading ⇄ waitingForURL / waitingForNetwork → completing → synced
                         └────────────► failed (retry budget exhausted only)
```

```swift
public struct UploadStateMachine {
    public enum Event { case planned([UploadPartRecord]), partSucceeded(Int, etag: String),
        partFailed(Int, FailureReason), urlsRefreshed([UploadPartRecord]),
        networkBecameAvailable, completed(remoteKey: String), cancelledByUser }
    public enum Effect { case enqueuePart(Int), refreshURLs([Int]), callComplete([Int: String]),
        scheduleRetry(Int, after: TimeInterval), deleteTempFile(Int), abort(FailureReason) }
    public func reduce(state: UploadJobState, event: Event) -> (UploadJobState, [Effect])
}
```

- `reduce` is deterministic, no I/O; `UploadCoordinator` is the only executor of effects.

| Cause | Reason | Handling |
|---|---|---|
| 401/403 on a presigned URL | `.urlExpired` | `waitingForURL`, **no budget consumed** |
| Not connected | `.offline` | `waitingForNetwork`, no budget consumed |
| 5xx, timeout, 429 (`Retry-After`) | `.serverTransient` / `.timeout` | Retry, budget consumed |
| 400, 404, 411, 413 | `.permanent` | Abort — the backend never returns these for retryable cases |
| ETag or checksum mismatch | `.integrity` | Abort, flag for the user |

- Retry: `delay = min(2s × 2^attempt, 300s) × jitter(0.8…1.2)`, max 5 attempts.
- Jitter is mandatory: 200 files failing at one signal loss must not retry together.

</dd></dl>

### 04.5 Policy

<dl><dd>

| Policy | Detail |
|---|---|
| Priority queue | Host-supplied priority ([03](01-field-work.md#03-issues-and-before-after-pairing)); plans low; stamped derivatives never upload |
| WiFi-only | `allowsCellularAccess = false`, on by default |
| Dedupe | Same `sha256` in a project → skip, reuse the existing `remoteKey` |
| Concurrency | 3 jobs, 4 connections per host — more times out together on weak networks |
| Local files | Never auto-deleted; cleanup is user-initiated and `synced`-only ([09](05-platform.md#09-diagnostics-and-observability)) |
| Logging | `{jobID, part n/N, bytes, elapsedMs, attempt, status, reason}`; never presigned URLs |

```swift
public enum UploadConstants {
    public static let partSizeBytes: Int = 8 * 1024 * 1024
    public static let singlePutThresholdBytes: Int = 5 * 1024 * 1024
    public static let maxConcurrentJobs: Int = 3
    public static let maxConnectionsPerHost: Int = 4
    public static let maxMaterializedPartsPerJob: Int = 2
    public static let minFreeDiskBytes: Int64 = 500 * 1024 * 1024
    public static let resourceTimeout: TimeInterval = 604_800
    public static let retryBaseDelay: TimeInterval = 2
    public static let retryCapDelay: TimeInterval = 300
    public static let maxRetryAttempts: Int = 5
    public static let sessionIdentifier: String = "app.dd.site.log.upload.background"
}
```

| Risk | Handling |
|---|---|
| Orphaned parts after abort | `DELETE /uploads/:id` + 7-day bucket lifecycle rule |
| Disk fills | Stop planning new jobs, keep running ones, show numbers |
| Account switch with pending jobs | Cancel old uid's jobs, delete temp files, never write into the new prefix |
| Clock skew vs `expiresAt` | 403 is the truth; `expiresAt` only drives proactive refresh |

**Done**

- 200 files / 2 GB complete with matching server hashes
- Kill mid-transfer resumes without re-uploading parts
- Airplane mode → `waitingForNetwork` with budget intact
- 60 s URL TTL refreshes automatically
- WiFi-only on cellular sends zero bytes

**Tests**

- Full (state × event) matrix
- Final part failure never calls `complete`
- Budget rules
- Exhausted budget keeps the original
- Backoff with stubbed RNG
- `ChunkPlanner` sizes
- Single-PUT threshold
- Dedupe
- All three reconciliation cases
- Priority order
- `MockTransport` flow with 503 at part 3
- Real kill on device

---

</dd></dl>

</dd></dl>

## 08. Auth and sync

<dl><dd>

- Modules: `SiteLog/Presentation/Sync`, `DataLayer` (sync engine), `Packages/DataLayer/Sources/DataLayer/DataSources/Remote/Networking` ([D03](00-overview.md#d03--node--postgresql-backend-hand-written-sync))

**Goal:** sign in once, work fully offline, sync all metadata across devices over a hand-written
delta protocol.

- Firebase is identity and crash reporting only; all data is in Postgres.

| In | Out |
|---|---|
| Firebase Auth (Sign in with Apple, email) | Firestore, in any role |
| Cursor-based delta pull, batched push, tombstones, LWW | Multi-user sharing, real-time co-editing, SSO |
| Offline mutation queue in SwiftData | Media in the sync protocol — bytes go to R2 |
| Account deletion | |

- Without Firestore, three things are ours: offline persistence (SwiftData mutation queue), delete
  propagation (tombstones), listener fan-out (`pg_notify`).
- **Remote media:** a pulled `Capture` carries its object key → presigned GET → shown with
  [Kingfisher](https://github.com/onevcat/Kingfisher) (downsampled, disk-cached, cache key without
  the query string). Local originals always read from disk ([D05](00-overview.md#d05--kingfisher-for-remote-images)).

### 08.1 Offline-first and auth

<dl><dd>

- Local is the source of truth while recording; the server once synced. Writes land in SwiftData and
  return immediately; no screen waits on the network.
- Launching offline after a prior sign-in goes straight in.
- `getIDToken(forcingRefresh: false)` on every request — never hand-cache it. The backend verifies
  with `checkRevoked: true`; keys embed the uid (`{uid}/{projectID}/…`). One 401 interceptor
  refreshes; no retry budget consumed.

</dd></dl>

### 08.2 Protocol

<dl><dd>

```
POST /sync/pull  { since: <rev>, limit }        → { changes: {table: [rows]}, nextRev, hasMore }
POST /sync/push  { mutations: [{ table, id, op, clientUpdatedAt, fields }] }
                                                → { results: [{ id, status: applied|superseded, serverRow? }], serverRev }
```

- **Revisions, not timestamps:** each row has a server-assigned `rev` from a per-user counter
  incremented in the write transaction, so it is gap-free and commit-ordered
  ([03-backend.md §7](03-backend.md#7-sync)).
- Conflicts: `captures`, `issue_captures` insert-only (UUIDs cannot conflict); everything else LWW on
  `clientUpdatedAt`, tie-broken by `id`; `checklist_results` per `(run, item)`;
  **`sessions.state` monotonic** (`draft < active < closed < exported`) so an offline device cannot
  reopen a signed report.
- Deletes are soft (`deleted_at` + new `rev`); tombstones purge after 90 days; a cursor older than
  that gets `{ resyncRequired: true }` and resyncs from 0.
- The client queues mutations in dependency order (`projects → locations → plan_sheets → sessions →
  captures → issues → issue_captures → annotations → checklist_*`); the server applies a batch in one
  transaction with deferred constraints.

</dd></dl>

### 08.3 Client engine

<dl><dd>

```swift
actor MetadataSyncEngine {          // Data/; triggered by use cases
    func sync() async throws        // pull, push, pull again if serverRev advanced
    func enqueue(_ mutation: Mutation) async
    func fullResync() async throws
}

enum SyncConstants {
    static let syncInterval: TimeInterval = 300
    static let pullPageSize: Int = 500
    static let pushBatchSize: Int = 200
    static let backoffBaseDelay: TimeInterval = 5
    static let backoffMaxDelay: TimeInterval = 600
    static let tombstoneRetentionDays: Int = 90
}
```

- Triggers: foreground, network restored, every `syncInterval`, queue reaching `pushBatchSize` —
  never per write.
- `superseded` is not a failure: adopt `serverRow`.
- Every cycle logs `{pulled, pushed, superseded, elapsedMs, cursor}`.
- **Account deletion:** in-app → reauthenticate → `DELETE /account` (server removes R2 objects and
  rows) → local store, Keychain, media; numbers shown first; final audit entry.

| Risk | Handling |
|---|---|
| Account switch with pending work | Cancel jobs, delete temp files, clear the queue |
| Cursor lost | Full resync from `rev 0` |
| Clock skew picks the wrong LWW winner | Accepted for metadata; captures are immutable |
| Sign in with Apple hides the email | Nothing depends on a real email |

**Done**

- Offline relaunch after sign-in
- A project created offline on A appears on B within one interval
- A delete on A stays deleted on B
- B cannot un-export A's session
- 80 generated locations sync as one batch
- Resync from 0 reproduces the store
- Token expiry mid-sync loses nothing

**Tests**

- Monotonic state across 16 pairs
- LWW tie-break
- Tombstones never resurrect
- Stale cursor → resync
- Queue survives termination in order
- `superseded` adoption
- 200 mutations = one request
- Account switch
- 10 concurrent 401s → one refresh

---

</dd></dl>

</dd></dl>

## 10. Realtime progress channel

<dl><dd>

- Module: `Packages/DataLayer/Sources/DataLayer/DataSources/Remote/Realtime` ([D04](00-overview.md#d04--websocket-realtime-channel))

**Goal:** learn what the server knows first — assembly done, hash checked, mismatch — without
polling 243 jobs. An **observation** channel on `URLSessionWebSocketTask`; never controls `UploadKit`.

**Boundary**

- Uploads work at 100% with the channel dead.
- Neither folder uses the other; the app layer turns events into `UploadStore` operations.
- Events may only **advance** a job; server silence never means "not done".
- CI builds the app with `Realtime` removed.

| Direction | Messages (line-delimited JSON) |
|---|---|
| Client → server | `auth {token}` · `subscribe {sessionID}` · `ping {at}` |
| Server → client | `snapshot {sessionID, completed[], failed[]}` · `jobCompleted {jobID, remoteKey, sha256}` · `jobFailed {jobID, reason}` · `pong {at}` |

- `snapshot` is always first after `subscribe` — it is the recovery path, so delivery need not be
  guaranteed. Missed messages are never replayed.
- The token goes in the first `auth` message, **never the URL**; no `auth` within `authTimeout` →
  closed; close code `4001` on expiry → refresh and reconnect.
- Connect only when foregrounded, a job is unsynced and the network is allowed; disconnect on
  background.
- Ping every `pingInterval` (cellular NAT drops silently); re-arm `receive` after every message
  (the classic silent bug); reconnect with its own backoff, unlimited.
- `jobCompleted` is trusted only if its `sha256` matches the local hash; otherwise it is an
  `integrity` failure. Unknown `jobID`s are ignored; handling is idempotent.

```swift
public enum RealtimeConstants {
    public static let pingInterval: TimeInterval = 30
    public static let pongTimeout: TimeInterval = 10
    public static let authTimeout: TimeInterval = 5
    public static let reconnectBaseDelay: TimeInterval = 1
    public static let reconnectMaxDelay: TimeInterval = 60
    public static let maxMessageBytes: Int = 64 * 1024   // larger closes without parsing
}
```

**Done**

- 50 jobs reach `synced` via events
- The same 50 with the flag off, only slower
- A two-minute drop reconnects and the snapshot restores state
- A wrong `sha256` raises a flag instead of `synced`
- Backgrounding closes within 1 s

**Tests**

- Decode all types + malformed
- Oversized message
- Missing `pong` → backoff
- Backoff cap and jitter
- Hash mismatch
- Applying one event 10× equals once
- Snapshot applies forward only
- Unknown `jobID`
- Flow against a mock WebSocket server

</dd></dl>
