# 19 — Performance profiling with Instruments

Module: none (tooling); signposts live next to the code they measure.

Instruments is Apple's profiler, bundled with Xcode. This is the plan for using it on the paths
where field conditions hurt: hundreds of files, long uploads, long-lived sockets.

## 1. Goal

- Know the real cost of the upload queue, the socket and capture before testers find it.
- Every performance claim in these docs has a measurement behind it.

## 2. Scope

| In | Out |
|---|---|
| Profiling runs on a real device, Release build | Automated performance CI |
| `os_signpost` intervals on hot paths | Third-party APM |
| A fixed set of scenarios and budgets | Crash reporting (see [09](09-diagnostics.md)) |

## 3. Templates

| Question | Template |
|---|---|
| Slow or janky | Time Profiler |
| Memory keeps growing, retain cycles | Allocations, Leaks |
| A SwiftUI view re-renders too often | SwiftUI |
| A request is slow or duplicated | Network |
| Battery cost of socket / upload | Energy Log |
| Time inside our own code | os_signpost / Points of Interest |

Run with ⌘I on a real device; simulator numbers are not representative. The scheme's Profile action
already builds Release.

## 4. Signposts

- Subsystem `app.dd.site.log`, one category per module (`Realtime`, `Upload`, `Capture`).
- Intervals around units of work, never around individual log lines.
- Metadata carries sizes and counts, never tokens, file names or user content.
- Near-free when Instruments is not attached, so they stay in Release.

| Module | Intervals |
|---|---|
| Realtime ([10](10-realtime-progress.md)) | `Connection`, `Message` |
| Upload ([04](04-upload-engine.md)) | `HashFile`, `UploadPart`, `Assemble` |
| Capture ([02](02-capture.md)) | `Capture`, `Thumbnail` |

## 5. Scenarios and budgets

| # | Scenario | Tool | Budget |
|---|---|---|---|
| 1 | Queue 243 files | Allocations | Memory stays flat; no growth linear in file count |
| 2 | 30-minute upload | Energy Log | No "High" energy impact while foregrounded |
| 3 | Socket open for 10 minutes | Energy Log, os_signpost | `Message` in microseconds; no wake-ups beyond the ping |
| 4 | Capture burst of 20 photos | Time Profiler, SwiftUI | No dropped frames on the capture screen |
| 5 | Open a session with 243 rows | SwiftUI | No row re-renders on unrelated updates |

Budgets are starting points; the first run replaces guesses with numbers and the table is updated.

## 6. Rules

- Profile before optimizing; a change is justified by a before/after trace.
- Save the trace for any scenario that fails a budget, and link it from the issue.
- A regression found here becomes a test where it can be expressed as one.

## 7. Known risks

| Risk | Handling |
|---|---|
| Profiling on a Debug build misleads | Always Release; state the build in the report |
| Signposts leak content | Metadata limited to sizes and counts, reviewed like logging |
| Numbers vary by device | Record the device model and OS with every result |

## 8. Definition of done

- All five scenarios run once on a real device with results recorded.
- Any scenario over budget has a filed issue with its trace.
- New modules ship their signposts with the module.

## 9. Tests

| Test | Kind |
|---|---|
| Scenarios 1–5 | manual, on device, before each TestFlight milestone |
| No signpost metadata contains a token or file name | code review checklist |
