# 04 — Upload engine (UploadKit)

Module: `Packages/UploadKit` — standalone, knows nothing about SiteLog

**Contents** — 1. [Goal](#1-goal) · 2. [Package boundary](#2-package-boundary) · 3. [Protocol](#3-protocol) · 4. [iOS constraints](#4-ios-constraints) · 5. [Strategy by size](#5-strategy-by-size) · 6. [State machine](#6-state-machine) · 7. [Policy](#7-policy) · 8. [Logging](#8-logging) · 9. [Known risks](#9-known-risks) · 10. [Definition of done](#10-definition-of-done) · 11. [Tests](#11-tests)

## 1. Goal

Move 150–250 files and several GB to object storage, surviving network loss, app suspension, OS
termination, device reboot, and presigned URL expiry.

## 2. Package boundary

`UploadKit` receives a file URL, metadata, an endpoint, and an injected `UploadStore`. It does not
import `Core` and has no knowledge of `Capture`, `Issue`, or `Session`.

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

- Records are plain `Sendable`, `Codable` structs defined in `UploadKit`; the app implements the
  protocol over SwiftData in `Persistence` and maps at the boundary.
- A package that reaches into the app's SwiftData models is neither standalone nor testable without
  the app. With this protocol, `UploadKit` ships `InMemoryUploadStore` and the whole state machine
  is testable with no app, no DB, no network.

```
Sources/UploadKit/
  UploadCoordinator.swift      # actor, public entry point
  UploadStateMachine.swift     # pure, synchronous, no I/O
  ChunkPlanner.swift           # part planning, temp file materialization
  PresignedURLProvider.swift   # protocol + HTTP implementation
  BackgroundSessionDelegate.swift
  Models/
Tests/UploadKitTests/
  InMemoryUploadStore.swift  MockTransport.swift
```

## 3. Protocol

Backend never touches bytes on the upload path. Full contract: [14-backend.md](14-backend.md).

| Step | Call | Returns |
|---|---|---|
| 1 | `POST /uploads` `{key, byteSize, contentType, sha256}` | `{mode:"single", uploadId, url, expiresAt}` **or** `{mode:"multipart", uploadId, partSizeBytes, parts:[…]}` |
| 2 | `PUT <presigned url>` (part temp file) | 200 + ETag |
| 3 | `POST /uploads/:id/complete` `{parts:[{number, etag}]}` | `{remoteKey, verificationCode, verified}` — idempotent |
| 4 | `POST /uploads/:id/parts/refresh` `{numbers:[…]}` | fresh URLs — **required** |
| 5 | `DELETE /uploads/:id` | abort, clean orphaned parts |

- Step 4, the refresh call, is mandatory ([14](14-backend.md) §3 numbers the endpoints
  independently — this table is a sequence, not an endpoint index): the core scenario is an app killed and reopened hours later, when signed
  URLs have expired and resume returns 403 across the board — indistinguishable from a retry bug.
- The backend picks the mode from `byteSize`; the client does not choose. Both sides must agree on
  `singlePutThresholdBytes` and `partSizeBytes`.
- Every request carries a Firebase ID token, verified before signing, and the key prefix must match
  the token's uid. Without that, the signing endpoint is an open relay into the bucket.
- `complete` is idempotent: a client killed before reading the response calls it again, and a `400`
  there would abort a finished job.

## 4. iOS constraints

| # | Constraint | Consequence |
|---|---|---|
| 1 | Background `URLSession` accepts only `uploadTask(with:fromFile:)` | Every part is written to a temp file first |
| 2 | Tasks created while backgrounded are treated as discretionary regardless of the flag | Enqueue the first batch in the foreground; say "will upload when idle" when the OS holds it |
| 3 | `taskIdentifier` is session-scoped and reused | Key on `taskDescription`, preserved across relaunch |
| 4 | Nothing survives in RAM after termination | Recreate the session with the same identifier and reconcile against the store |

Disk discipline for constraint 1:

- Materialize at most `maxMaterializedPartsPerJob` parts ahead per job.
- Delete each part file on 200 + ETag.
- Check free space before planning; below `minFreeDiskBytes`, defer and inform the user.

```swift
task.taskDescription = "\(jobID.rawValue)#\(partNumber)"

func urlSession(_ s: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    guard let key = task.taskDescription else { /* log + abandon */ return }
    Task { await coordinator.handleCompletion(key: key, response: task.response, error: error) }
}
```

Session configuration:

| Setting | Value | Reason |
|---|---|---|
| `isDiscretionary` | `false` | The OS would otherwise defer to overnight charging |
| `sessionSendsLaunchEvents` | `true` | Wakes the app when transfers finish |
| `timeoutIntervalForResource` | `604_800` (7 days) | A three-day trip without WiFi must still upload on return |
| App delegate | `application(_:handleEventsForBackgroundURLSession:completionHandler:)` | Required to resume after a launch event |

### 4.1 Cold-launch reconciliation

| Situation | Action |
|---|---|
| Task alive, record exists | Reattach, do not re-enqueue |
| Task alive, no record | Cancel and log — the record is untrustworthy |
| Record `uploading`, no task | Reset to `pending`, re-enqueue |

- Usual cause of "stuck at 60% forever".
- Client reconciliation cannot see server state; [10](10-realtime-progress.md) supplies a snapshot
  in one round trip. `UploadKit` does not import it — the app layer applies events via `UploadStore`.

## 5. Strategy by size

| Size | Strategy |
|---|---|
| < 5 MB (most photos) | Single presigned PUT, one request |
| ≥ 5 MB (video, RAW) | Multipart, uniform 8 MB parts |

- S3 requires 5 MB minimum per non-final part.
- **R2 additionally requires every non-final part to be exactly equal in size.**
- So `ChunkPlanner` splits by fixed size, never into "N equal pieces".
- A 3 MB photo through multipart costs 3 round trips for a 1-request job — minutes lost across 200 photos.

## 6. State machine

Pure, synchronous, no I/O.

```
                  ┌──────────────────────────────┐
                  ↓                              │
pending → planning → uploading ⇄ waitingForURL ──┘
             │           │  │
             │           │  └→ waitingForNetwork ─┘
             │           ↓
             │       completing → synced
             ↓           │
          failed ←───────┘
```

```swift
public struct UploadStateMachine {
    public enum Event {
        case planned(parts: [UploadPartRecord])
        case partSucceeded(number: Int, etag: String)
        case partFailed(number: Int, reason: FailureReason)
        case urlsRefreshed(parts: [UploadPartRecord])
        case networkBecameAvailable
        case completed(remoteKey: String)
        case cancelledByUser
    }
    public enum Effect {
        case enqueuePart(Int)
        case refreshURLs(numbers: [Int])
        case callComplete(etags: [Int: String])
        case scheduleRetry(number: Int, after: TimeInterval)
        case deleteTempFile(number: Int)
        case abort(reason: FailureReason)
    }
    public func reduce(state: UploadJobState, event: Event) -> (UploadJobState, [Effect])
}
```

- `reduce` is deterministic and touches no network, disk, or clock.
- `UploadCoordinator` (an actor) is the only executor of `Effect`.
- The split makes kill-mid-flight, expired URLs, and a failing final part testable in a few lines.

### 6.1 Failure classification

| Cause | Reason | Handling |
|---|---|---|
| 403 / 401 on a presigned URL | `.urlExpired` | → `waitingForURL`, **no budget consumed** |
| `NSURLErrorNotConnectedToInternet` | `.offline` | → `waitingForNetwork`, no budget consumed |
| 500, 502, 503, 504 | `.serverTransient` | retry, budget consumed |
| Timeout | `.timeout` | retry, budget consumed |
| 400, 404, 411, 413 | `.permanent` | abort immediately — the backend must never return these for a retryable condition ([14](14-backend.md)) |
| 429 | `.serverTransient` | retry after `Retry-After` |
| ETag or checksum mismatch | `.integrity` | abort, flag for the user |

Expired URLs and offline are normal operating conditions, not failures. Charging them to the budget
means half a day on site exhausts it and everything lands in `failed`.

### 6.2 Retry

```
delay = min(base * 2^attempt, cap) * jitter
base 2s   cap 300s   jitter 0.8...1.2   maxAttempts 5
```

Attempts count only `.serverTransient` and `.timeout`. Jitter is mandatory — 200 files failing at
one signal loss would otherwise retry simultaneously.

## 7. Policy

| Policy | Detail |
|---|---|
| Priority queue, not FIFO | Host-supplied `priority` ([03](03-issue-tracking.md)); plans at `PlanConstants.uploadPriority`; derived stamped images never upload |
| WiFi-only toggle | `allowsCellularAccess = false`, **on by default** |
| Dedupe by `sha256` within a project | Same hash → skip, point `remoteKey` at the existing object, log it |
| Concurrency | 3 jobs, `httpMaximumConnectionsPerHost = 4` — higher makes everything time out together on weak networks |
| Never auto-delete local files | Cleanup is user-initiated and touches only `synced` files ([09](09-diagnostics.md)) |

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
    public static let retryJitterRange: ClosedRange<Double> = 0.8...1.2
    public static let maxRetryAttempts: Int = 5
    public static let sessionIdentifier: String = "com.sitelog.upload.background"
}
```

## 8. Logging

```swift
logger.info("Upload part succeeded", metadata: [
    "jobID": "\(job.id)", "part": "\(number)/\(job.partCount)",
    "bytes": "\(partSize)", "elapsedMs": "\(elapsed)", "attempt": "\(attempt)"
])
logger.error("Upload part failed", metadata: [
    "jobID": "\(job.id)", "part": "\(number)/\(job.partCount)",
    "status": "\(statusCode)", "reason": "\(reason)", "attempt": "\(attempt)",
    "error": "\(String(reflecting: error))"
])
```

Never log presigned URLs — they carry signing credentials.

## 9. Known risks

| Risk | Handling |
|---|---|
| Orphaned parts on R2 after abort | `DELETE /uploads/:id`, backed by a 7-day bucket lifecycle rule |
| Disk fills mid-session | Stop planning new jobs, keep running ones, report concrete numbers |
| Account switch with pending jobs | Cancel the old uid's jobs, delete temp files, never write into the new uid's prefix |
| Clock skew breaking `expiresAt` | 403 is the source of truth; `expiresAt` only drives proactive refresh |

## 10. Definition of done

- 200 files / 2 GB complete over WiFi; server hashes match local hashes.
- Kill mid-transfer → relaunch resumes without re-uploading completed parts.
- Airplane mode mid-transfer → `waitingForNetwork`; restoring resumes with the budget untouched.
- Presigned URL expiry (60 s TTL test) → automatic refresh, never `failed`.
- WiFi-only on cellular → zero bytes transferred.
- Zero warnings; builds independently of the app.

## 11. Tests

| Test | Kind |
|---|---|
| `reduce` across the full (state × event) matrix, no cell skipped | unit, pure |
| Final part fails → not `synced`, `complete` never called | unit |
| `.urlExpired` spends no budget; `.serverTransient` does | unit |
| Budget exhausted → `failed`, temp deleted, **original kept** | unit |
| Backoff sequence with a stubbed RNG | unit |
| `ChunkPlanner`: uniform parts, odd final part, exact multiples | unit |
| Sub-threshold file selects single PUT, no `uploadId` | unit |
| Dedupe: identical `sha256` → `synced` with zero requests | unit |
| Cold-launch reconciliation, all three cases | unit, `InMemoryUploadStore` |
| Priority ordering across 5 mixed jobs | unit |
| Full flow through `MockTransport` with 503 at part 3 | integration |
| Real kill mid-transfer on device | manual |

`MockTransport` implements `protocol UploadTransport` and scripts per-part responses: 200, 403,
503, timeout, wrong ETag.
