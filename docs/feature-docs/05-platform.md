# Platform

Everything around the features: diagnostics, release pipeline, notifications and deep links,
profiling.

**Specs** — [09 Diagnostics](#09-diagnostics-and-observability) · [17 CI/CD and TestFlight](#17-cicd-and-testflight) · [18 Push and deep links](#18-push-notifications-and-deep-links) · [19 Instruments](#19-performance-profiling-with-instruments)

---

## 09. Diagnostics and observability

Module: `SiteLog/Presentation/Diagnostics`

**Goal:** users answer "where are my photos?" themselves; one exported file is enough for a developer
to diagnose; cleanup can never delete anything not yet uploaded.

### 09.1 Upload status screen

```
Session 05 Sep — Ánh Dương Tower
████████████░░░░  187/243 files · 1.8 GB / 2.4 GB · ~6 min remaining
⚠ 4 waiting: Waiting for WiFi (3) · Waiting for a new upload link (1)
✕ 2 failed — [Retry]
```

- **Waiting is never red** — `waitingForNetwork` and `waitingForURL` are normal.
- Plain-language reasons, never enum names; "Will upload when the device is idle" when the OS holds
  tasks; estimates from the trailing `throughputWindow`.
- A closed realtime channel is not an error, only slower.

### 09.2 Integrity checks and cleanup

| Check | Detects |
|---|---|
| Record with no file / file with no record | Lost media / orphan from a crash |
| Recomputed hash ≠ `sha256` (originals only) | Corruption or substitution |
| Audit chain HMAC | Tampered log |
| Temp part with no job; `uploading` with no task | Garbage; stuck job → reset to `pending` |
| Derived image with no source | Stale stamped copy |

Default to a random sample of `integritySampleSize`, with a background "verify everything".

Cleanup: **only `synced` files are eligible**, even with a full disk; numbers first ("Delete 156
uploaded files, freeing 1.4 GB. 12 not yet uploaded will be kept."); temp parts, prebuffer, tiles and
derived images are a separate "reclaimable" line; every cleanup writes an audit entry.

### 09.3 Diagnostic bundle and status flags

`diagnostic-<date>.zip`: `device.json`, `permissions.json`, `upload-state.json` (no URLs),
`integrity.json`, `logs.ndjson` (24 h). **Redact on write:** strip URLs, tokens, emails, user text,
GPS; keep ids, enums, counters, status codes.

Red flags: permission denied (camera, mic, location, Bluetooth); free disk below `minFreeDiskBytes`;
thermal `.serious`+; battery below `lowBatteryThreshold` with pending uploads; offline with pending
jobs; audit chain failed; metadata sync older than `staleSyncThreshold`.

### 09.4 App-wide logging

- `os.Logger`, subsystem `app.dd.site.log`, category per module (`capture`, `upload`, `report`,
  `plans`, `devicelink`, `sync`, `security`).
- Every action logs with data, successes included; every `catch` logs `String(reflecting:)`; no
  `print` (CI greps for it).
- Firebase Crashlytics initializes first; non-fatals via `Crashlytics.crashlytics().record(error:)`
  with the same structured data ([ADR 0007](../adr/0007-firebase-crashlytics.md)).

```swift
enum DiagnosticsConstants {
    static let throughputWindow: TimeInterval = 60
    static let integritySampleSize: Int = 50
    static let logRetentionHours: Int = 24
    static let staleSyncThreshold: TimeInterval = 86_400
    static let lowBatteryThreshold: Float = 0.20
}
```

**Done:** all seven integrity conditions detected; the bundle has no URL, token, email, text or
coordinate; cleanup with 12 `pending` files deletes none of them.
**Tests:** detectors on a fake filesystem; cleanup never touches `pending`/`failed`; redaction
snapshot; estimates never `NaN` or negative; flags at 7 boundaries; `uploading` without task resets.

---

## 17. CI/CD and TestFlight

Modules: `fastlane/`, `.github/workflows/`

**Goal:** every PR proves lint, builds, unit and snapshot tests and coverage
([testing.md](../testing.md)); a tag becomes a TestFlight build with no manual Xcode step; no
certificates or keys stored in CI. App Store review submission stays manual.

| Lane | Does |
|---|---|
| `test` | `xcodegen`, `xcodebuild test` per package on the simulator, app unit + snapshot tests, coverage per package |
| `beta` | Release archive, upload dSYMs to Crashlytics, upload to TestFlight without waiting |
| `release` | Same, waits for processing |

| Workflow | Trigger | Runs |
|---|---|---|
| PR checks | PR, push to `main` | `swiftlint --strict`, lane `test` |
| TestFlight | tag `v*`, manual | lane `beta`, in the protected `testflight` environment |

**Runners.** The repo is private, so hosted macOS minutes bill at 10× (≈200 per month). Ubuntu jobs
run on every push: `Domain` purity, `UploadKit`/`Realtime` boundary, `print(` grep, `gitleaks`,
SwiftLint/swift-format, backend `vitest` + `tsc` + ESLint + migrations on a throwaway Postgres. macOS
jobs run on the self-hosted development Mac: each package standalone with warnings as errors and
scoped tests per PR; nightly the app without `Realtime` and the full suite. A hosted macOS fallback
job stays disabled. Self-hosting is safe only because the repo is private.

**Signing and versions.** Xcode-managed signing via `-allowProvisioningUpdates` + App Store Connect
API key (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_CONTENT`, App Manager role), written to a temp file
and deleted after the build. Build number = latest TestFlight + 1; `MARKETING_VERSION` in
`project.yml`, bumped by hand. Release: `git tag v1.0.0 && git push origin v1.0.0`.

**Risks:** fork PRs never see secrets (environment-scoped); tags serialize build numbers; pin the
runner's Xcode on the first mismatch.
**Done:** a SwiftLint warning or failing package test fails the PR; pushing `v0.0.1` produces a
TestFlight build with no local step; the repo holds no `.p8`, certificate or profile.

---

## 18. Push notifications and deep links

Modules: `SiteLog/Presentation/Notifications`, `SiteLog/Presentation/DeepLinks`

**Goal:** a notification tap or a `sitelog://` URL opens the exact session or issue, through one
shared `DeepLink` type, and a link during cold launch is not lost. Rich notifications, universal
links and silent push as an upload trigger are out.

- Format `sitelog://<route>/<id>` (`session/42`, `issue/7`); wrong scheme, unknown route or missing
  id is ignored and logged. The parser is pure; ids are opaque data.
- Payload `{ "aps": { "alert": {…} }, "deepLink": "sitelog://issue/42" }` carries a destination only;
  state comes from the local store.
- Authorization is requested at a moment that makes sense, not blindly at first launch; the token is
  logged truncated, replaceable, and re-sent when it changes.
- Routing: `URL / push → parser → router (pending) → view consumes and navigates`. The router
  **holds** the destination until a view consumes it (cold launch), consuming clears it, and a deleted
  target lands on a safe screen.
- Setup: Push capability, `aps-environment`, `sitelog` URL scheme and `remote-notification`
  background mode in `project.yml`. Simulator: `xcrun simctl push booted app.dd.site.log
  payload.json`, `xcrun simctl openurl booted sitelog://session/42`.

**Risks:** crafted ids from other apps are data, re-checked at the destination; pushes for another
account are ignored; the app works fully with push denied.
**Done:** links open from Safari and `simctl`; a tap opens the target when killed, backgrounded or
foregrounded; garbage is ignored without a crash.
**Tests:** parser routes and rejections; payload with/without `deepLink`; router holds until consumed;
cold-launch link survives (UI test).

---

## 19. Performance profiling with Instruments

Tooling only; signposts live next to the code they measure.

**Goal:** know the real cost of the upload queue, the socket and capture before testers do; every
performance claim in these docs has a measurement behind it. Always a real device, Release build.

| Question | Template |
|---|---|
| Slow or janky | Time Profiler |
| Memory growth, retain cycles | Allocations, Leaks |
| A SwiftUI view re-renders too often | SwiftUI |
| Slow or duplicated requests | Network |
| Battery cost of socket / upload | Energy Log |
| Time inside our own code | os_signpost / Points of Interest |

Signposts: subsystem `app.dd.site.log`, intervals `Connection`/`Message` (Realtime),
`UploadPart`/`Reconcile` (Upload), `Capture`/`HashFile`/`Thumbnail` (Capture); metadata is sizes and
counts only; they stay in Release.

| # | Scenario | Budget |
|---|---|---|
| 1 | Queue 243 files | Flat memory, no growth linear in file count |
| 2 | 30-minute upload | No "High" energy impact in the foreground |
| 3 | Socket open 10 minutes | `Message` in microseconds; no wake-ups beyond ping |
| 4 | Burst of 20 photos | No dropped frames |
| 5 | Session with 243 rows | No re-renders on unrelated updates |

Profile before optimizing; justify a change with a before/after trace; save traces for failed
budgets; record device and OS with every result. Scenarios run on device before each TestFlight
milestone.
