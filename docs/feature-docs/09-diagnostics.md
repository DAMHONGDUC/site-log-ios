# 09 — Diagnostics & observability

Module: `App/Features/Diagnostics`

An offline-first app with background uploads is one where the user cannot see what is happening.
This is how "where are my photos?" gets answered without Xcode.

## 1. Goal

- Users answer for themselves: how much uploaded, what is stuck, why.
- One exported file is enough for a developer to diagnose a report.
- Disk cleanup that cannot delete anything not yet uploaded.

## 2. Scope

| In | Out |
|---|---|
| Upload status screen | Management analytics dashboards (v2) |
| Storage breakdown, synced vs unsynced vs reclaimable | Direct DB editing from the UI |
| Controlled cleanup | |
| Integrity checks | |
| Redacted diagnostic bundle | |
| System status flags | |

## 3. Upload status screen

```
┌──────────────────────────────────────┐
│ Session 05 Sep — Ánh Dương Tower     │
│ ████████████░░░░  187/243 files      │
│ 1.8 GB / 2.4 GB · ~6 min remaining   │
│                                      │
│ ⚠ 4 waiting                          │
│   • Waiting for WiFi (3)             │
│   • Waiting for a new upload link (1)│
│ ✕ 2 failed — [Retry]                 │
└──────────────────────────────────────┘
```

| Rule | Reason |
|---|---|
| Separate **waiting** from **failed**; waiting is never red | `waitingForNetwork` and `waitingForURL` are normal states |
| Plain-language reasons, never enum names | |
| Say "Will upload when the device is idle" when the OS holds tasks | Do not promise what is not controlled ([04](04-upload-engine.md)) |
| Estimates use the trailing `throughputWindow` | Whole-session averages mislead |
| A closed [realtime channel](10-realtime-progress.md) is not an error | The screen is still correct, only slower |

## 4. Integrity checks

| Check | Detects |
|---|---|
| Capture record with no file | Lost media |
| File in `media/` with no record | Orphan (crash between write and DB insert) |
| Recomputed hash ≠ stored `sha256` | Corruption or substitution (originals only) |
| Audit chain HMAC | Tampered log ([07](07-security.md)) |
| Temp part with no job | Upload garbage |
| `uploading` with no task | Stuck job → reset to `pending` |
| Derived image with no source capture | Stale stamped copy ([12](12-annotation.md)) |

Full verification over several GB is slow — default to a random sample of `integritySampleSize`,
with a background "verify everything" option.

## 5. Cleanup

Until `synced`, local media is the only copy.

- **Only `synced` files are eligible**, even when the disk is full.
- State numbers first: "Delete 156 uploaded files, freeing 1.4 GB. 12 not yet uploaded will be kept."
- Temp parts, prebuffer segments, plan tiles, and derived stamped images are regenerable and need no
  confirmation; storage stats list them as a separate "reclaimable" line.
- Every cleanup writes an audit entry.

## 6. Diagnostic bundle

```
diagnostic-<date>.zip
  device.json       # model, iOS, free space, battery, thermal
  permissions.json  # camera, mic, location, bluetooth, notifications
  upload-state.json # jobs and parts, NO URLs
  integrity.json    # last verification result
  logs.ndjson       # last 24 h of os.log, redacted
```

**Redact on write, not on read.** Strip presigned URLs, tokens, emails, user text, GPS. Keep ids,
enums, counters, status codes. Users send this over chat — if it carries sensitive data, every bug
report is a leak.

## 7. System status flags

| Flag | Red when |
|---|---|
| Camera / mic / location / bluetooth | denied |
| Free disk | below `minFreeDiskBytes` |
| Thermal state | `.serious` or higher |
| Battery | below `lowBatteryThreshold` with pending uploads |
| Connectivity | offline with pending jobs |
| Audit chain | verification failed |
| Metadata sync | older than `staleSyncThreshold` |

## 8. App-wide logging rules

- `Logger` (os.log), subsystem `com.sitelog`, category per module: `capture`, `upload`, `report`,
  `plans`, `devicelink`, `sync`, `security`.
- Every action logs with data; successes included.
- Every `catch` logs `String(reflecting:)`, never a hand-written message. Catch broad, not narrow.
- **No `print`** — CI fails on `grep -rn "print(" Sources/`.
- Crashlytics initializes first; each startup step guarded and logged individually.

```swift
enum DiagnosticsConstants {
    static let throughputWindow: TimeInterval = 60
    static let integritySampleSize: Int = 50
    static let logRetentionHours: Int = 24
    static let staleSyncThreshold: TimeInterval = 86_400
    static let lowBatteryThreshold: Float = 0.20
}
```

## 9. Definition of done

- All seven integrity conditions reproduced manually are detected.
- The bundle contains no signed URL, token, email, free text, or coordinate.
- Cleanup with 12 `pending` files deletes none of them.
- `grep -rn "print(" Sources/` is empty.
- Zero warnings.

## 10. Tests

| Test | Kind |
|---|---|
| Detectors find missing files, orphans, orphan temp parts | unit, fake filesystem |
| Cleanup never touches `pending` or `failed` | unit |
| Redaction: signed URL + email + free text → clean output | unit, snapshot |
| Time estimation under fluctuating throughput never yields `NaN` or negatives | unit |
| Status flags across 7 boundary combinations | unit |
| `uploading` with no task resets to `pending` | unit |
