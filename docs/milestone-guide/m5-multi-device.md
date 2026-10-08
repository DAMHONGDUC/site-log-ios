# M5 — Multi-device

- M5 — Multi-device · 60h · skeleton guide.

## Contents

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [P60 · Auth and sync protocols](#p60--auth-and-sync-protocols)
4. [P61 · Firebase Auth](#p61--firebase-auth)
5. [P62 · Backend pull and push](#p62--backend-pull-and-push)
6. [P63 · Sync engine: pull](#p63--sync-engine-pull)
7. [P64 · Sync engine: push and conflicts](#p64--sync-engine-push-and-conflicts)
8. [P65 · Deletes propagate](#p65--deletes-propagate)
9. [P66 · Two-device convergence test](#p66--two-device-convergence-test)
10. [P67 · Real sign-in screens](#p67--real-sign-in-screens)
11. [P68 · Account settings](#p68--account-settings)
12. [P69 · Sync status](#p69--sync-status)
13. [P70 · Real auth and sync, two-device demo](#p70--real-auth-and-sync-two-device-demo)
14. [Milestone done](#milestone-done)

## Overview

- **Goal:** sign in once, sync every metadata row across devices, deletes propagate.
- **Demo:** a second device sees the same data and deletes propagate.
- **Specs:** [08 Auth and sync](../feature-docs/02-upload-sync.md#08-auth-and-sync), [14 §7 Sync](../feature-docs/03-backend.md#7-sync)
- **UI skeleton:** this milestone’s screens already exist at ~30% of Figma on `FakeData` (2026-10-08). UI parts add the view model, states and previews; the visual finish is [M7](m7-ui-finish.md).
- **Status:** skeleton — parts, files, order, tests. Full, tested code is added when this milestone starts, built on the real code from the milestone before.

| Part | Track | Hours | Status | What |
|---|---|---|---|---|
| [P60](#p60--auth-and-sync-protocols) | `Contract` | 2h | not start | Auth and sync protocols |
| [P61](#p61--firebase-auth) | `Logic` | 7h | not start | Firebase Auth |
| [P62](#p62--backend-pull-and-push) | `Logic` | 6h | not start | Backend pull and push |
| [P63](#p63--sync-engine-pull) | `Logic` | 8h | not start | Sync engine: pull |
| [P64](#p64--sync-engine-push-and-conflicts) | `Logic` | 12h | not start | Sync engine: push and conflicts |
| [P65](#p65--deletes-propagate) | `Logic` | 6h | not start | Deletes propagate |
| [P66](#p66--two-device-convergence-test) | `Logic` | 8h | not start | Two-device convergence test |
| [P67](#p67--real-sign-in-screens) | `UI` | 3h | not start | Real sign-in screens — VM on skeleton |
| [P68](#p68--account-settings) | `UI` | 3h | not start | Account settings — VM on skeleton |
| [P69](#p69--sync-status) | `UI` | 2h | not start | Sync status — VM on skeleton |
| [P70](#p70--real-auth-and-sync-two-device-demo) | `Join` | 3h | not start | Real auth and sync, two-device demo |

### Order

- P60 contract first.
- Auth + backend + sync engine (P61–P66) in parallel with UI (P67–P69).
- P70 joins. P64 is over 8h: split it.

## Target structure

```text
Backend/migrations/0002_sync_core.sql, 0003_metadata.sql   # P62
Backend/src/routes/sync.ts                                 # P62
SiteLog/
├── Domain/Auth/, Sync/                      # P60
├── Data/Sync/MetadataSyncEngine.swift (actor), MutationQueue          # P63–P65
├── App/AppDelegate.swift                    # P61: FirebaseApp.configure() first
└── Presentation/Access/SignIn/ (real), Settings/Account/, Uploads/SyncTab/   # P67–P69
```

## P60 · Auth and sync protocols

- **Goal:** `AuthService`, `SyncEngine` protocols and fakes.

### Tests

- Fakes drive sign-in and account screens

## P61 · Firebase Auth

- **Goal:** Sign in with Apple and email; ID token on every request.
- **Spec:** [08.1](../feature-docs/02-upload-sync.md#081-offline-first-and-auth)

### Steps

1. `getIDToken(forcingRefresh: false)` per request; one 401 interceptor refreshes.
2. Offline relaunch after sign-in goes straight in.
3. Sign in with Apple capability via `project.yml`.

### Tests

- 10 concurrent 401s → one refresh

## P62 · Backend pull and push

- **Goal:** `/sync/pull` and `/sync/push` on `sync_state.last_rev`.
- **Spec:** [14 §5.2, §7](../feature-docs/03-backend.md#7-sync)

### Steps

1. Row lock makes revs gap-free; LWW in SQL; `sessions.state` monotonic.

### Tests

- Stale cursor → resyncRequired
- Constraints reject bad rows

## P63 · Sync engine: pull

- **Goal:** cursor-based pull into SwiftData.
- **Spec:** [08.3](../feature-docs/02-upload-sync.md#083-client-engine)

### Steps

1. Triggers: foreground, network back, every `syncInterval`.

### Tests

- Resync from 0 reproduces the store

## P64 · Sync engine: push and conflicts

- **Goal:** offline mutation queue, batched push, `superseded` adoption.
- **Spec:** [08.2](../feature-docs/02-upload-sync.md#082-protocol)

### Steps

1. Split when you start (queue · push · conflicts).
2. Queue in dependency order.

### Tests

- Monotonic state across 16 pairs
- LWW tie-break
- 200 mutations = one request

## P65 · Deletes propagate

- **Goal:** soft deletes, tombstones, 90-day purge.
- **Spec:** [08.2](../feature-docs/02-upload-sync.md#082-protocol)

### Tests

- Tombstones never resurrect

## P66 · Two-device convergence test

- **Goal:** two clients against one backend converge.

### Steps

1. Run in CI against a throwaway Postgres.

### Tests

- Create on A appears on B; delete on A stays deleted on B; B cannot un-export A’s session

## P67 · Real sign-in screens

- **Goal:** A2 buttons wired: Sign in with Apple, email screens.
- **Spec:** Mockup A2

### Steps

1. Replace the logging stubs in `SignInViewModel` from M0.

### Tests

- View models
- Snapshots

## P68 · Account settings

- **Goal:** profile, sign out, delete account (numbers first, native alert).
- **Spec:** [08.3](../feature-docs/02-upload-sync.md#083-client-engine)

### Tests

- View model
- Snapshot

## P69 · Sync status

- **Goal:** last synced and errors in the Sync tab.

### Tests

- View model
- Snapshot

## P70 · Real auth and sync, two-device demo

- **Goal:** real Firebase + sync behind the screens.

| File | Holds |
|---|---|
| `SiteLog/App/AppDependencies.swift` | Swap fake registrations for the real ones |

### Steps

1. Register real auth and sync.
2. Run the demo on two devices.

### Done when

- Second device sees the same data
- Deletes propagate

## Milestone done

| Check | How |
|---|---|
| Demo | Two devices converge; deletes propagate |
| Roadmap | P60–P70 ticked |
