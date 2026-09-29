# 08 — Auth & sync

Modules: `App/Features/Auth`, `App/Features/Sync`

Firebase provides **identity and crash reporting only**. All application data lives in Postgres
behind the backend ([14](14-backend.md)); there is no Firestore.

**Contents** — 1. [Goal](#1-goal) · 2. [Scope](#2-scope) · 3. [Offline-first rules](#3-offline-first-rules) · 4. [Auth](#4-auth) · 5. [Sync protocol](#5-sync-protocol) · 6. [Client engine](#6-client-engine) · 7. [Account deletion](#7-account-deletion) · 8. [Known risks](#8-known-risks) · 9. [Definition of done](#9-definition-of-done) · 10. [Tests](#10-tests)

## 1. Goal

- Sign in once, keep the session, work fully offline.
- Sync all metadata across devices over a hand-written delta protocol.
- Authorize the backend to sign presigned URLs.

## 2. Scope

| In | Out |
|---|---|
| Firebase Auth (Sign in with Apple, email/password) | Firestore, in any role |
| ID token as `Authorization` for every backend call | Multi-user sharing and roles (v2) |
| Cursor-based delta pull, batched push | Real-time collaborative editing |
| Tombstones, LWW, monotonic session state | Enterprise SSO |
| Offline mutation queue in SwiftData | Media in the sync protocol — bytes go to R2 |
| Account deletion | |

Dropping Firestore removes an SDK that handled three things for free. All three are now ours:

| Lost | Replaced by |
|---|---|
| Offline persistence | A mutation queue in SwiftData that survives termination |
| Delete propagation | Tombstones + a purge window |
| Listener fan-out | `pg_notify` ([14](14-backend.md) §10) |

## 3. Offline-first rules

**Local is the source of truth while recording. The server is the source of truth once synced.**

- Writes land in SwiftData first and return to the UI immediately; the sync engine follows.
- No screen waits on the network; no blocking spinners on primary screens.
- Launching offline after a prior sign-in goes straight in. Only refresh-token expiry or revocation
  forces re-authentication.

## 4. Auth

```swift
func authorizedRequest(_ base: URLRequest) async throws -> URLRequest {
    let token = try await Auth.auth().currentUser?.getIDToken(forcingRefresh: false)
    var request = base
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    return request
}
```

| Rule | Detail |
|---|---|
| Never hand-cache the token | `getIDToken` refreshes near expiry (1 h lifetime) |
| Backend verifies every request | `verifyIdToken(token, checkRevoked: true)` |
| Object keys embed the uid | `{uid}/{projectID}/…`; signing is refused on mismatch |
| 401 → `waitingForURL` | No retry budget consumed; same path as URL expiry ([04](04-upload-engine.md)) |

## 5. Sync protocol

Two endpoints, both batched, both idempotent. Full backend behaviour: [14](14-backend.md).

```
POST /sync/pull  { since: <rev>, limit }
  → { changes: { projects: [...], sessions: [...], … }, nextRev, hasMore }

POST /sync/push  { mutations: [ { table, id, op, clientUpdatedAt, fields } ] }
  → { results: [ { id, status: "applied"|"superseded", serverRow? } ], serverRev }
```

### 5.1 Revisions, not timestamps

Every row carries a server-assigned `rev`. The client stores one cursor per account and asks for
`rev > cursor`.

Timestamps cannot be the cursor:

- Two rows written in the same millisecond are indistinguishable.
- A clock that steps backwards silently skips records.

`rev` comes from a per-user counter incremented inside the same transaction as the write, so it is
gap-free **and** commit-ordered for that user ([14](14-backend.md) §7).

### 5.2 Conflict resolution

| Data | Rule |
|---|---|
| `captures`, `issue_captures` | Insert-only, client-generated UUID — cannot conflict |
| `projects`, `locations`, `issues`, `plan_sheets`, `annotations`, templates, phrases, branding | Last-write-wins on `clientUpdatedAt`, tie-broken by row `id` |
| `sessions.state` | **Monotonic**: `draft < active < closed < exported`, advance only |
| `checklist_results` | LWW per `(run_id, template_item_id)` — re-answering an item overwrites only that item |

`sessions.state` must be monotonic. An offline device could otherwise write `active` over another
device's `exported` and reopen a signed report.

- LWW uses the device clock, which is not trustworthy — hence `trustedTime` on captures
  ([12](12-annotation.md) §7).
- Acceptable here: metadata conflicts are rare in a single-owner model, and the cost of a wrong
  winner is an edited title, not lost evidence.

### 5.3 Deletes

Firestore propagated deletes through its listeners. Without it, a delete that only removes a local
row is invisible to every other device, and the row returns on the next pull.

- Deletes are **soft**: set `deleted_at`, bump `rev`, push like any other mutation.
- Pull returns tombstones; the client deletes locally and keeps nothing.
- The server purges tombstones older than `tombstoneRetention` (90 days).
- A client whose cursor is older than the purge window must **full resync** (`since: 0`). The server
  signals this by returning `{ resyncRequired: true }`.

### 5.4 Push ordering

A child row rejected because its parent has not arrived yet is the most common failure in a
hand-written sync engine.

- The client queues mutations in dependency order:
  `projects → locations → plan_sheets → sessions → captures → issues → issue_captures → annotations → checklist_*`
- The server applies one batch in one transaction with deferred constraints, so order **within** a
  batch does not matter.
- Ordering still matters **across** batches, which is why the queue preserves it.

## 6. Client engine

```swift
actor MetadataSyncEngine {
    func sync() async throws          // pull, then push, then pull again if push advanced serverRev
    func enqueue(_ mutation: Mutation) async
    func fullResync() async throws
}
```

| Trigger | Note |
|---|---|
| Foreground entry | |
| Network restored | |
| Every `syncInterval` (5 min) | |
| After a push queue reaches `pushBatchSize` | Never per write — 80 bulk-generated locations must not be 80 requests |

- The mutation queue is a SwiftData table, so it survives termination.
- Failed pushes retry with backoff; a `superseded` result is not a failure — the client adopts the
  returned `serverRow` and drops its own.
- Every cycle logs `{pulled, pushed, superseded, conflicts, elapsedMs, cursor}`.

```swift
enum SyncConstants {
    static let syncInterval: TimeInterval = 300
    static let pullPageSize: Int = 500
    static let pushBatchSize: Int = 200
    static let backoffBaseDelay: TimeInterval = 5
    static let backoffMaxDelay: TimeInterval = 600
    static let tombstoneRetentionDays: Int = 90
}
```

## 7. Account deletion

1. In-app, not via support email.
2. Reauthenticate first.
3. `DELETE /account` removes R2 objects, upload rows, and every metadata row for the uid
   ([14](14-backend.md)) — the app never holds R2 credentials.
4. Then delete the local store, Keychain items, and media files.
5. Show concrete numbers before deleting; write a final audit entry ([07](07-security.md)).

## 8. Known risks

| Risk | Handling |
|---|---|
| Account switch with pending uploads or mutations | Cancel old jobs, delete temp files, clear the mutation queue; never write into the new uid's prefix |
| Cursor lost or corrupted | Full resync from `rev 0`; expensive but always correct |
| Clock skew making LWW pick the wrong winner | Accepted for metadata; never applied to captures, which are immutable |
| Token revoked elsewhere | Handle 401 in one interceptor, not scattered checks |
| Sign in with Apple hides the email | Nothing may depend on a real email address |
| Backend unreachable for days | The app is fully usable; only cross-device visibility is delayed |

## 9. Definition of done

- Sign in → airplane mode → kill → relaunch enters directly with all recording features.
- A project created offline on device A appears on B within one `syncInterval` of connectivity.
- Deleting a location on A removes it on B; it does not reappear on the next pull.
- A exports a session; B offline sets `active`; after sync the state is still `exported`.
- 80 bulk-generated locations sync as one batch, not 80 requests.
- Full resync from `rev 0` reproduces an identical local store.
- Token expiry mid-sync refreshes automatically; no mutation is lost.

## 10. Tests

| Test | Kind |
|---|---|
| Monotonic `SessionState` merge across all 16 pairs | unit, `Core` |
| LWW on `clientUpdatedAt` with a stable id tie-break | unit |
| Tombstone applied locally deletes the row and does not resurrect it | unit |
| Cursor older than the purge window triggers full resync | unit |
| Mutation queue survives termination and preserves dependency order | integration |
| `superseded` result replaces the local row without user-visible loss | unit |
| Push of 200 mutations is one request | unit |
| Account switch clears the queue and cancels jobs | unit |
| 401 triggers exactly one refresh when 10 requests fail concurrently | unit, mock |
