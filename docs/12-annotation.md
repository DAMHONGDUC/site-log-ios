# 12 — Annotation & verifiable stamps

Modules: `Packages/Capture` (rendering), `Core` (models)

Two market-standard features that appear to conflict with capture immutability, resolved the same
way: **the original file is never touched; everything is a separate layer or a derived copy.**

## Goal

- Mark up a photo with arrows, boxes, circles, and text in under 10 seconds.
- Produce a shareable image stamped with time, location, and project.
- Make the timestamp defensible rather than trivially spoofable.

## Scope

| In | Out |
|---|---|
| Vector annotation layer per capture | Annotation on video |
| Stamped derivative images | Freehand smoothing beyond basic simplification |
| Trusted-time capture and confidence levels | Editing pixels of the original, ever |
| On-device dictation and voice notes | |
| Per-capture verification code | |

## 1. Annotations as a vector layer

```swift
@Model final class Annotation {
    var id: UUID
    var capture: Capture
    var shapes: [AnnotationShape]   // Codable JSON
    var createdAt: Date
    var updatedAt: Date
}

enum AnnotationShape: Codable, Sendable, Equatable {
    case arrow(from: CGPoint, to: CGPoint, style: ShapeStyle)
    case rect(CGRect, style: ShapeStyle)
    case ellipse(CGRect, style: ShapeStyle)
    case freehand(points: [CGPoint], style: ShapeStyle)
    case text(String, at: CGPoint, style: TextStyle)
}
```

Coordinates are normalized 0…1 against the original image, so a layer drawn on a phone renders
correctly at report resolution.

Competitors burn annotations into the stored JPEG, which destroys the original and makes the hash
meaningless. Keeping vectors separate gives:

| Benefit | Detail |
|---|---|
| Hash stays valid forever | `Capture.sha256` verifies against an untouched original |
| Editable and removable | No re-encoding |
| Both versions printable | Report can show annotated and clean |
| Cheap to sync | A few KB of JSON, not another upload |

Annotation edits write an audit entry; the layer is explicitly **not** part of the immutable set.

## 2. Editor

```
Thumbnail → [Annotate]
  → [Arrow] [Box] [Circle] [Pen] [Text] · color · undo · done
```

- Arrow is the default tool — it is what people reach for.
- Stroke width scales with image dimensions, not screen points, so a phone mark is visible on A4.
- Undo/redo capped at `maxUndoSteps`.
- No save button; changes commit on exit.

## 3. Stamped derivatives

Reports and shared images carry a burned-in stamp: date/time, coordinates and accuracy, project and
location code, company logo.

```
media/<…>/<captureID>.jpg              ← original, immutable, hashed, uploaded
derived/<…>/<captureID>-stamped.jpg    ← regenerable, never hashed, never evidence
```

Generated on demand, cached, safe to delete. Excluded from integrity checks
([09](09-diagnostics.md)) precisely because they are not evidence.

## 4. Dictation and voice notes

- `SFSpeechRecognizer` with `requiresOnDeviceRecognition = true`. Sending site audio to a server
  conflicts with [07](07-security.md).
- Vietnamese and English locales; falls back to the phrase library when unavailable.
- A voice note is an ordinary audio `Capture` — hashed and uploaded like any other file. Dictated
  text lands in `Issue.detail` and stays editable.

## 5. Trusted time

`Date()` reflects the device clock, which anyone can change in Settings. For an app whose premise is
chain of custody that is a real weakness — and the point a competitor built a product on.

```swift
struct TrustedTimestamp: Codable, Sendable {
    let deviceTime: Date
    let uptimeNanos: UInt64         // monotonic, detects clock jumps within a session
    let serverOffset: TimeInterval? // last known (serverTime − deviceTime)
    let offsetMeasuredAt: Date?
    let confidence: TimeConfidence
}
```

| Confidence | Condition |
|---|---|
| `.serverVerified` | Offset measured within `serverOffsetValidity` and under `maxAcceptableOffset` |
| `.sessionConsistent` | No server contact, but uptime matches wall-clock progression since launch |
| `.deviceOnly` | Clock jumped, or relaunched with no server contact |

- Offset comes from the `Date` header of any successful backend response — no extra endpoint.
- **Confidence is printed in the report**, never hidden.
- A capture is never rejected for low confidence. Basements have no signal; that is the use case.

## 6. Verification code

- On upload completion the backend countersigns the capture hash and returns a short code.
- The report prints it under each image; the recipient resolves it to `{sha256, receivedAt, uid}`.
- Without a server-side record, a hash printed by the app that computed it proves only internal
  consistency.
- Unsynced captures print "not yet verified", never a fabricated code.

```swift
enum AnnotationConstants {
    static let maxUndoSteps: Int = 20
    static let strokeWidthRatio: CGFloat = 0.004   // × image width
    static let minTextPointSize: CGFloat = 14
    static let derivedImageMaxPixelSize: CGFloat = 2000
}

enum TrustedTimeConstants {
    static let serverOffsetValidity: TimeInterval = 3600
    static let maxAcceptableOffset: TimeInterval = 120
}
```

## Known risks

| Risk | Handling |
|---|---|
| Users expecting annotations to be "in" the photo elsewhere | Share and export always emit the stamped, annotated derivative; only the archive keeps the clean original |
| Derived cache growth | Regenerable and evictable, counted separately in storage stats |
| Speech permission denied | Falls back to keyboard and phrase library with no error |
| Backend clock poisoning the offset | Offsets above `maxAcceptableOffset` are discarded; confidence drops to `.sessionConsistent` |

## Definition of done

- Annotate with 5 shapes, relaunch, the layer renders identically over an untouched original whose
  hash still verifies.
- Phone-drawn annotations render at correct proportions in an A4 PDF.
- Deleting the derived cache loses nothing.
- Moving the device clock forward a day drops confidence to `.deviceOnly` and the report says so.
- Dictation runs offline in airplane mode.
- Zero warnings.

## Tests

| Test | Kind |
|---|---|
| `AnnotationShape` Codable round-trip for all five cases | unit, pure |
| Normalized coordinates render identically at two output sizes | unit |
| Annotating never mutates the original (hash before/after) | unit |
| Undo stack respects `maxUndoSteps`, never underflows | unit |
| Confidence for fresh offset, stale offset, clock jump, relaunch | unit, injected clock |
| Offset above `maxAcceptableOffset` rejected | unit |
| Unsynced capture renders "not yet verified" | unit |
| Stamp legible at portrait, landscape, square | snapshot |
