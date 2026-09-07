# 08 — Auth & metadata sync

Modules: `App/Features/Auth`, `App/Features/Sync`

Firebase covers auth, metadata, and crash only. File bytes go through
[UploadKit](04-upload-engine.md) to R2.

## Goal

- Sign in once, keep the session, work fully offline.
- Sync metadata (not media) across devices.
- Authorize the backend to sign presigned URLs.

## Scope

| In | Out |
|---|---|
| Firebase Auth (Sign in with Apple, email/password) | Media in Firestore (1 MB doc limit) |
| ID token as `Authorization` for backend calls | Multi-user sharing and roles (v2) |
| Two-way offline-first Firestore sync | Enterprise SSO |
| Account deletion | |

## Offline-first rules

**Local is the source of truth while recording. Server is the source of truth once synced.**

- Writes land in SwiftData first and return immediately; Firestore follows.
- No screen waits on the network; no blocking spinners on primary screens.
- Launching offline after prior sign-in goes straight in. Only refresh-token expiry or revocation
  forces re-authentication.

## Backend authorization

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
| Backend verifies before signing | Firebase Admin SDK |
| Keys embed the uid | `{uid}/{projectID}/{sessionID}/{captureID}.{ext}`; signing is refused on mismatch |
| 401 → `waitingForURL` | No retry budget consumed; same path as URL expiry |

## Firestore layout

```
users/{uid}/projects/{projectID}
users/{uid}/projects/{projectID}/{sessions|locations|issues|planSheets}/{id}
users/{uid}/checklistTemplates/{id}
users/{uid}/phrases/{id}
users/{uid}/branding/default
```

`Capture` syncs as a lightweight descriptor only: id, kind, sha256, capturedAt, remoteKey,
verificationCode, locationID.

### Conflict resolution

| Type | Strategy |
|---|---|
| `Capture` | Never conflicts — immutable, client-generated UUID |
| `Issue`, `Location`, `Project`, `Annotation` | Last-write-wins on server `updatedAt` |
| `Session.state` | Monotonic: `draft < active < closed < exported`, **advance only** |
| `ChecklistRun` results | Append-only per item; last answer wins per `ChecklistResult` |

`Session.state` must be monotonic — an offline device could otherwise write `active` over another
device's `exported` and reopen a signed report.

### Sync worker

- `actor MetadataSyncEngine`, runs on foreground entry, network restore, and every `syncInterval`.
- Never per write — bulk-generating 80 locations would become 80 writes.
- Batches up to `maxBatchWrites`, exponential backoff, logs `{pushed, pulled, conflicts, elapsedMs}`.

## Account deletion

1. In-app, not via support email.
2. Reauthenticate first.
3. Delete: Firestore subtree, R2 objects under `{uid}/`, local store, Keychain, media files.
4. Show concrete numbers before deleting.
5. Write a final audit entry ([07](07-security.md)).

```swift
enum SyncConstants {
    static let syncInterval: TimeInterval = 300
    static let maxBatchWrites: Int = 400          // Firestore caps at 500
    static let backoffBaseDelay: TimeInterval = 5
    static let backoffMaxDelay: TimeInterval = 600
}
```

## Known risks

| Risk | Handling |
|---|---|
| Account switch with pending uploads | Cancel old jobs, delete temp files, never write into the new prefix |
| Firestore quota | ~280 docs per session; batch writes and track volume from day one |
| Token revoked elsewhere | Handle 401 in one interceptor, not scattered checks |
| Sign in with Apple hides the email | Nothing may depend on a real email address |

## Definition of done

- Sign in → airplane mode → kill → relaunch enters directly with all recording features.
- A project created offline on device A appears on B within 60 s of connectivity.
- A exports a session, B offline sets `active`; after sync the state is still `exported`.
- Token expiry mid-upload refreshes automatically; the job never enters `failed`.
- Account deletion leaves no object under `{uid}/`.

## Tests

| Test | Kind |
|---|---|
| Monotonic `SessionState` merge across all 16 pairs | unit, `Core` |
| LWW on `updatedAt` with a stable id tie-break | unit |
| Account switch cancels old jobs and deletes temp files | unit |
| 401 triggers exactly one refresh when 10 requests fail concurrently | unit, mock |
| 500 documents split into exactly 2 batches | unit |
| Security rules: uid A cannot read `users/{B}` | integration, emulator |
| Backend rejects signing a key that does not match the token uid | integration |
