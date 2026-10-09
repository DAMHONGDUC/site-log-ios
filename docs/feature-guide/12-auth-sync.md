# F12 — Auth and multi-device sync

<dl><dd>

- F12 · 60h · skeleton guide — full code is added when this feature starts.

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain — Auth and sync protocols](#1-domain--auth-and-sync-protocols)
4. [2. Fake data — Fake auth and sync](#2-fake-data--fake-auth-and-sync)
5. [3. View models — Wire sign-in, account, sync status](#3-view-models--wire-sign-in-account-sync-status)
6. [4. Backend — Pull and push endpoints](#4-backend--pull-and-push-endpoints)
7. [5. Real data — Firebase Auth and sync engine](#5-real-data--firebase-auth-and-sync-engine)
8. [Tests (after the feature works)](#tests-after-the-feature-works)
9. [Feature done](#feature-done)

</dd></dl>

## Overview

<dl><dd>

- **Goal:** Auth and multi-device sync end to end: Domain → fake data → view models → real data → tests.
- **Demo:** a second device sees the same data; deletes propagate.
- **Spec:** [08](../feature-docs/02-upload-sync.md#08-auth-and-sync), [14 §7 Sync](../feature-docs/03-backend.md#7-sync)
- **Starts from:** the skeleton screens (~30% of Figma) that read `Core/Fakes/FakeData.swift`.
- **Fakes:** only in `SiteLog/Data/Fakes/`, registered in `AppDependencies`; the dev menu seeds / clears them through `FakeDevDataActions`.
- **File tags:** <b class="tag-new">New</b> create the file · <b class="tag-edit">Edit</b> change only the part shown.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--auth-and-sync-protocols) | Domain | 1h | not start | Auth and sync protocols |
| [2](#2-fake-data--fake-auth-and-sync) | Fake data | 1h | not start | Fake auth and sync |
| [3](#3-view-models--wire-sign-in-account-sync-status) | View models | 8h | not start | Wire sign-in, account, sync status |
| [4](#4-backend--pull-and-push-endpoints) | Backend | 6h | not start | Pull and push endpoints |
| [5](#5-real-data--firebase-auth-and-sync-engine) | Real data | 44h | not start | Firebase Auth and sync engine |

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
Backend/migrations/0002_sync_core.sql, 0003_metadata.sql   # 4
Backend/src/routes/sync.ts                                 # 4
SiteLog/
├── Domain/Auth/, Sync/                    # 1: AuthService, SyncEngine protocols
├── Data/Fakes/                            # 2: FakeAuthService, FakeSyncEngine
├── Data/Sync/MetadataSyncEngine.swift (actor), MutationQueue   # 5
├── App/AppDelegate.swift                  # 5: FirebaseApp.configure() first
└── Presentation/Access/SignIn/, Settings/Account/, Uploads/UploadStatus/   # 3
```

</dd></dl>

## 1. Domain — Auth and sync protocols

<dl><dd>

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Domain/Auth/` | `AuthService` (Apple, email, sign out, delete account) |
| <b class="tag-new">New</b> | `Domain/Sync/` | `SyncEngine` (status, last synced, errors) |

</dd></dl>

## 2. Fake data — Fake auth and sync

<dl><dd>

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `SiteLog/Data/Fakes/FakeAuthService.swift` | Signs in “Hanh Nguyen” instantly |
| <b class="tag-new">New</b> | `SiteLog/Data/Fakes/FakeSyncEngine.swift` | “Synced 2 minutes ago” |

</dd></dl>

## 3. View models — Wire sign-in, account, sync status

<dl><dd>

| Action | Skeleton folder | View model work |
|---|---|---|
| <b class="tag-edit">Edit</b> view model | `Presentation/Access/SignIn/` | A2: replace the logging stubs in `SignInViewModel` (F01) |
| <b class="tag-new">New</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Settings/Account/` | Profile, sign out; delete account alert in Settings |
| <b class="tag-edit">Edit</b> view model · <b class="tag-edit">Edit</b> view | `Presentation/Uploads/UploadStatus/` | Last synced, errors |

#### Steps

<dl><dd>

1. Add `<Screen>ViewModel.swift` next to the view: `@MainActor @Observable`, use cases through `@Injected`.
2. In the view, replace `FakeData…` with view-model state; keep the layout (visual finish is F16).
3. Loading, empty (`DSEmptyState`) and error states; previews for each.
4. Delete this feature's `Fake*` types from `Core/Fakes/FakeData.swift` once nothing uses them.

</dd></dl>

</dd></dl>

## 4. Backend — Pull and push endpoints

<dl><dd>

- **Goal:** `/sync/pull` and `/sync/push` on `sync_state.last_rev`.
- **Spec:** [14 §5.2, §7](../feature-docs/03-backend.md#7-sync)

#### Steps

<dl><dd>

1. Row lock makes revs gap-free; LWW in SQL; `sessions.state` monotonic.

</dd></dl>

</dd></dl>

## 5. Real data — Firebase Auth and sync engine

<dl><dd>

<details open>
<summary><strong>5.1 Firebase Auth</strong></summary>
<dl><dd>

- **Goal:** Sign in with Apple and email; ID token on every request.
- **Spec:** [08.1](../feature-docs/02-upload-sync.md#081-offline-first-and-auth)

#### Steps

<dl><dd>

1. `getIDToken(forcingRefresh: false)` per request; one 401 interceptor refreshes.
2. Offline relaunch after sign-in goes straight in.
3. Sign in with Apple capability via `project.yml`.

</dd></dl>
</details>

<details open>
<summary><strong>5.2 Sync engine: pull</strong></summary>
<dl><dd>

- **Goal:** cursor-based pull into SwiftData.
- **Spec:** [08.3](../feature-docs/02-upload-sync.md#083-client-engine)

</dd></dl>

#### Steps

<dl><dd>

1. Triggers: foreground, network back, every `syncInterval`.

</dd></dl>
</details>

<details open>
<summary><strong>5.3 Sync engine: push and conflicts</strong></summary>
<dl><dd>

- **Goal:** offline mutation queue, batched push, `superseded` adoption.
- **Spec:** [08.2](../feature-docs/02-upload-sync.md#082-protocol)

</dd></dl>

#### Steps

<dl><dd>

1. Split when you start (queue · push · conflicts).
2. Queue in dependency order.

</dd></dl>
</details>

<details open>
<summary><strong>5.4 Deletes propagate</strong></summary>
<dl><dd>

- **Goal:** soft deletes, tombstones, 90-day purge.
- **Spec:** [08.2](../feature-docs/02-upload-sync.md#082-protocol)

</dd></dl>
</details>

<details open>
<summary><strong>5.5 Two-device convergence test</strong></summary>
<dl><dd>

- **Goal:** two clients against one backend converge.

</dd></dl>

#### Steps

<dl><dd>

1. Run in CI against a throwaway Postgres.

</dd></dl>
</details>

<details open>
<summary><strong>5.6 Real auth and sync, two-device demo</strong></summary>
<dl><dd>

- **Goal:** Real Firebase + sync behind the screens.

| Action | File | Holds |
|---|---|---|
| <b class="tag-edit">Edit</b> | `SiteLog/App/AppDependencies.swift` | Swap the fake registrations for the real ones |

</dd></dl>

#### Steps

<dl><dd>

1. Register real auth and sync.
2. Run the demo on two devices.

</dd></dl>

#### Done when

<dl><dd>

- Second device sees the same data
- Deletes propagate

</dd></dl>
</details>

</dd></dl>

</dd></dl>

## Tests (after the feature works)

<dl><dd>

**4. Backend — Pull and push endpoints**

- Stale cursor → resyncRequired
- Constraints reject bad rows

**5. Real data — Firebase Auth and sync engine**

- 10 concurrent 401s → one refresh
- Resync from 0 reproduces the store
- Monotonic state across 16 pairs
- LWW tie-break
- 200 mutations = one request
- Tombstones never resurrect
- Create on A appears on B; delete on A stays deleted on B; B cannot un-export A’s session

</dd></dl>

## Feature done

<dl><dd>

| Check | How |
|---|---|
| Demo | Two devices converge; deletes propagate |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F12 steps ticked |

</dd></dl>
