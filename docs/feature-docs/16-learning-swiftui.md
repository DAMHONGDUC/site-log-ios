# 16 — Learning plan: Swift & SwiftUI

Modules: all. Audience: one developer, experienced outside Apple platforms, new to Swift.

- The other documents assume the reader already writes SwiftUI. This one removes that
  assumption.
- Learning happens **inside this repository**, not in throwaway sample apps: every exercise below
  produces a file that survives into the shipped app.
- The plan is written to be gated, not read. A phase ends when its checkpoint passes on a device,
  the same rule [ROADMAP.md](../../ROADMAP.md) applies to milestones.

## 1. Learner profile

| Fact | Consequence for this plan |
|---|---|
| Fluent in another language and ecosystem | No time spent on loops, functions, or what a type is |
| No Swift, no Xcode, no Apple frameworks | Two weeks of language and tooling before any UI |
| Toolchain is Xcode 26.4 / Swift 6.3 | Strict concurrency is on from line one; it is taught early, not patched in later |
| 10–15 hours per week, ~2 hours per day | One lesson per day, one checkpoint per week |
| Target is SiteLog itself | Every exercise is a part from [ROADMAP.md](../../ROADMAP.md) |

## 2. Effect on the roadmap

- The hour estimates in [ROADMAP.md](../../ROADMAP.md) already include learning each feature area
  while building it, so the phases below are an order to learn in, not extra time on top.
- **Phase 0** (language and concurrency, about 20–30 hours) comes before `P02` and is not in those
  estimates.
- **If time is fixed:** apply the stop rule in [ROADMAP.md](../../ROADMAP.md) (stop after `M4`, skip
  sync and the realtime channel, ship single-device).
- **Never compress Phase 0:** an upload engine written without understanding `actor` isolation
  costs more than it saves.

## 3. Daily rhythm

Two hours, four blocks, every working day.

| Block | Minutes | What happens |
|---|---|---|
| Concept | 30 | One idea, explained against an equivalent from a stack already known |
| Build | 60 | The learner types; no generated solutions for exercise code |
| Explain back | 20 | The mechanism is described out loud, without the editor open |
| Log | 10 | One line in the learning log: what was built, what is still unclear |

The explain-back block is the actual test. Code that compiles for reasons the author cannot state
is a liability in an offline-first app where failures appear hours later in a basement.

## 4. Phases

| Phase | Week | Subject | Produces | Roadmap parts |
|---|---|---|---|---|
| Phase 0 | 0.1 | Swift: the language | Domain types, pure state machine, tests | before P02 |
| Phase 0 | 0.2 | Swift: concurrency and Swift 6 isolation | Async repository layer, actor-based queue skeleton | before P02 |
| Phase 1 | 1–2 | SwiftUI: views, layout, navigation | Project → session → location screens | P07–P09 |
| Phase 2 | 3–4 | State, observation, SwiftData | The same screens, backed by real storage | P05–P09 |
| Phase 3 | 5–6 | UIKit bridging, AVFoundation, progress UI | Capture screen, upload queue screen | P10–P21 |
| Phase 4 | 7–8 | Canvas, gestures, transforms, PDFKit | Annotation, plan pins, report preview | P25–P31 |
| Phase 5 | 9–10 | Module boundaries, DI, testable views | Feature packages split as [00](00-project-info.md) §4 specifies | P02–P04 |
| Phase 6 | 11–12 | Performance, animation, accessibility | M6 polish pass | P49–P50 |

## 5. Phase 0.1 — the language (week 0.1)

Xcode, a Swift package, and `swift test`. No app target yet.

| Day | Concept | Exercise |
|---|---|---|
| 1 | Xcode, SPM layout, `let`/`var`, optionals, value semantics | `Project`, `Session`, `Location` as `struct`; understand why mutation copies |
| 2 | `enum` with associated values, exhaustive `switch` | `UploadState` as a pure state machine — the one [04](04-upload-engine.md) requires |
| 3 | Protocols, extensions, generics, `some` vs `any` | `protocol CaptureStore` plus an in-memory implementation |
| 4 | Closures, `throws`, `Result`, Swift Testing | Tests for day 2: expired presigned URL, failing final part, kill mid-flight |
| 5 | Reference types, `class`, identity, ARC, retain cycles | Explain-back: why `Capture` is a value and the upload engine is not |

**Gate:** `swift test` passes with at least eight tests over the state machine, and every
transition in [04](04-upload-engine.md) §6 is either implemented or explicitly listed as missing.

## 6. Phase 0.2 — concurrency (week 0.2)

Swift 6.3 with strict concurrency. This week exists because the upload engine ([04](04-upload-engine.md)) is unwritable without it.

| Day | Concept | Exercise |
|---|---|---|
| 1 | `async`/`await`, `Task`, structured concurrency | Make `CaptureStore` async; call it from a test |
| 2 | Cancellation, `withTaskGroup`, `TaskGroup` error propagation | Hash four files concurrently; cancel halfway and prove no partial write |
| 3 | `actor`, isolation, reentrancy | `actor UploadQueue` holding pending parts |
| 4 | `@MainActor`, `Sendable`, `nonisolated`, data-race errors | Fix a deliberately broken file until it compiles under strict concurrency |
| 5 | `AsyncStream`, `AsyncSequence` | Progress events from the queue, consumed in a test |

**Gate:** zero concurrency warnings, and the learner can say which thread each line runs on for
three given functions.

## 7. Phase 1 — SwiftUI fundamentals (weeks 1–2)

The mental model first: a `View` is a value describing what the screen should be, recreated freely,
never a mutable object held onto.

1. **View identity and `body`** — why `body` runs often, what is expensive inside it.
2. **Modifier order** — `.padding().background()` and `.background().padding()` are different
   pictures; know why before debugging layout.
3. **Layout system** — parent proposes, child chooses, parent places. `HStack`, `VStack`, `ZStack`,
   `frame`, `layoutPriority`, `Spacer`, safe area.
4. **`List` and `ForEach`** — identity, `id:`, why a wrong id breaks animation and selection.
5. **`NavigationStack`** — value-based routing, `navigationDestination`, programmatic paths.
6. **`Form` and controls** — the project and session creation screens in
   [01](01-project-session.md).
7. **Previews** — `#Preview` with fixture data, the fastest feedback loop on this platform.

**Build:** the `P07`–`P09` screens — project list, project detail, session start, location tree — on
in-memory fixtures, no persistence.

**Gate (M0 territory):** navigate list → detail → session → 80 locations on a device, zero
warnings, every screen has a working preview.

## 8. Phase 2 — state and storage (weeks 3–4)

1. **`@State`** — ownership, and the rule that state lives at the lowest common ancestor.
2. **`@Binding`** — passing write access down without passing the model.
3. **`@Observable`** — the Observation macro, not `ObservableObject`; iOS 18 makes the old path
   obsolete for this codebase.
4. **`@Environment` and `@Bindable`** — dependency passing without constructor threading.
5. **Lifecycle** — `.task(id:)`, `.onChange`, cancellation when a view disappears mid-flight.
6. **SwiftData** — `@Model`, `ModelContainer`, `@Query`, contexts, and where the boundary with
   `Core` sits per [00](00-project-info.md) §3.
7. **Migrations** — versioned schemas before there is production data to lose.

**Build:** replace week 1–2 fixtures with SwiftData. Entities from [00](00-project-info.md) §3.

**Gate (M1 territory):** create a project, add 80 locations, capture a stub record, kill the app,
relaunch — everything intact, in airplane mode.

## 9. Phase 3 — capture and transfer (weeks 5–6)

1. **`UIViewRepresentable`** — bridging `AVCaptureVideoPreviewLayer` into SwiftUI, including
   `updateUIView` and coordinator lifetime.
2. **`AVCaptureSession`** — configuration on a background queue, permissions, orientation.
3. **Streaming hashes** — `CryptoKit` over a file being written, per [02](02-capture.md).
4. **Background `URLSession`** — why it cannot be an `async` call and what the delegate must
   persist.
5. **Progress UI** — `AsyncStream` from phase 0.2 rendered without redrawing the whole list.
6. **Error surfaces** — a failed upload states what the user can do, per [09](09-diagnostics.md).

**Build:** capture screen (`P10`–`P12`) and upload queue screen (`P16`–`P21`).

**Gate (M2 territory):** 200 files reach R2, surviving app kill and airplane mode.

## 10. Phase 4 — drawing and documents (weeks 7–8)

1. **`Canvas` and `Path`** — the annotation vector layer of [12](12-annotation.md).
2. **Gestures** — `DragGesture`, `MagnifyGesture`, composition, simultaneous recognition.
3. **Coordinate spaces and transforms** — pin placement on a zoomed floor plan,
   [11](11-floorplan-pins.md); pins store plan-relative coordinates, never screen points.
4. **`PDFKit`** — rendering and previewing the report of [05](05-reporting.md).
5. **`ShareLink` and export** — getting the deliverable off the device.

**Gate (M3 territory):** annotate a photo, drop a pin, export a signed PDF from a real session.

## 11. Phase 5 — architecture (weeks 9–10)

1. **SPM module boundaries** — the package graph from [00](00-project-info.md); a feature must not
   import another feature.
2. **Dependency injection** — protocol boundaries, and previews that inject fakes.
3. **Testable view logic** — what belongs in a view, what belongs in an `@Observable` model, and
   what belongs in `Core`.
4. **Build hygiene** — zero warnings as a gate, not an aspiration.

**Gate:** each package builds standalone; a feature package compiles without the app target.

## 12. Phase 6 — polish (weeks 11–12)

1. **Performance** — Instruments, the SwiftUI profiler, finding the view that redraws 60 times a
   second.
2. **Animation and transitions** — `withAnimation`, `matchedGeometryEffect`, transaction control.
3. **Accessibility** — labels, Dynamic Type, VoiceOver on the capture flow.
4. **Appearance** — dark mode, and a UI readable in direct sunlight on a site.

**Gate:** M6 as written in [ROADMAP.md](../../ROADMAP.md).

## 13. Rules of engagement

| Rule | Reason |
|---|---|
| Exercise code is typed by the learner, never generated | Reading code produces recognition, not recall |
| Explanations come before the editor opens | Naming the mechanism first exposes what is missing |
| A phase gate that fails repeats the phase | Dates move; gates do not |
| Errors are read in full, out loud, before a fix is attempted | Swift diagnostics are precise; skipping them is the main time sink |
| One learning-log line per day | Makes a stuck topic visible after three days, not three weeks |
| Specs are the source of truth | If a lesson and a spec disagree, the spec wins or the spec gets fixed |

## 14. Resources

| Resource | Use for |
|---|---|
| Apple's SwiftUI tutorials and framework documentation | First contact with each API |
| WWDC sessions on Observation, SwiftData, and Swift concurrency | The reasoning behind iOS 17+ API shapes |
| Swift Programming Language (official book) | Language reference during phase 0 |
| Hacking with Swift, 100 Days of SwiftUI | Extra drills when a topic does not land |
| This repository's specs | The actual requirements; everything above is scaffolding |

## 15. Definition of done

- The learner ships M1 without assistance on the SwiftUI portions.
- Every phase gate above passed on a real device, in order.
- The learning log shows no topic open for more than five days.
- Zero warnings at every gate, including strict-concurrency warnings.
