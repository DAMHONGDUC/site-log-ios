# 02 — Capture pipeline

Module: `Packages/Capture`

Hand-written. `UIImagePickerController` and `PhotosPicker` are excluded — they hide
`AVCaptureSession` control, and a hash only means something for a file the app produced.

## Goal

One `AVCaptureSession` serving photo, video, and audio without teardown. Every file hashed before
it reaches the DB.

## Scope

| In | Out |
|---|---|
| Photo, video + audio, standalone audio | Photo editing (captures are immutable) |
| Torch, zoom, camera flip, elapsed timer | Photo library import |
| Continuous capture with a thumbnail strip | Annotation (separate layer, [12](12-annotation.md)) |
| GPS, `deviceModel`, `capturedAt`, `trustedTime` | |
| SHA-256 on close | |
| 30-second pre-record buffer (later phase) | |

## Session topology

```
AVCaptureSession
├── inputs:  AVCaptureDeviceInput(video: back/front)
│            AVCaptureDeviceInput(audio: mic)
├── outputs: AVCapturePhotoOutput          → photos
│            AVCaptureVideoDataOutput      → sample buffers → AVAssetWriter
│            AVCaptureAudioDataOutput      → sample buffers → AVAssetWriter
└── preview: AVCaptureVideoPreviewLayer (UIViewRepresentable)
```

`AVAssetWriter` over `AVCaptureMovieFileOutput`: required for the pre-record buffer, and gives
bitrate control that matters when GB travel over 3G. Cost: manual state, timestamps, rotation.

| Work | Queue |
|---|---|
| `startRunning`/`stopRunning`, configuration | `sessionQueue` (serial, `.userInitiated`) |
| Sample buffer delivery | `videoDataQueue` / `audioDataQueue` |
| Writer appends | `writerQueue` |
| Hashing | `hashQueue` (`.utility`) |
| UI state | `@MainActor` |

Never call `startRunning()` on main — it blocks 300–800 ms.

## State machine

```
idle → configuring → ready → capturingPhoto → ready
                       ↓                        ↑
                   recording ──────────────────┘
                       ↓
                   finalizing (finishWriting + hash)
```

`interrupted` is a separate branch (call, backgrounding, camera claimed elsewhere). If recording,
**finalize rather than discard** — 8 seconds beats none.

## Metadata

| Field | Source | When unavailable |
|---|---|---|
| `capturedAt` | `Date()` at `didFinishProcessingPhoto` | always present |
| `trustedTime` | Device clock + monotonic uptime + cached server offset | degrades to `.deviceOnly` |
| `latitude` / `longitude` | `CLLocationManager`, most recent fix | **`nil`, capture proceeds** |
| `horizontalAccuracy` | same | `nil` |
| `deviceModel` | `utsname` | always present |
| `sha256` | computed from the closed file | always present |

- The device clock is user-settable, so `capturedAt` alone cannot support a chain-of-custody claim;
  `TrustedTimestamp` and its confidence levels are in [12](12-annotation.md) §5.
- GPS never blocks capture. `desiredAccuracy = .nearestTenMeters`; a fix older than
  `locationStaleAfter` is written as `nil`, never as a wrong coordinate.

## Hashing

```swift
func sha256(ofFileAt url: URL) throws -> String {
    let handle = try FileHandle(forReadingFrom: url)
    defer { try? handle.close() }
    var hasher = SHA256()
    while let chunk = try handle.read(upToCount: HashConstants.streamingChunkBytes),
          chunk.isEmpty == false {
        hasher.update(data: chunk)
    }
    return hasher.finalize().map { String(format: "%02x", $0) }.joined()
}
```

- Stream in chunks; `Data(contentsOf:)` on a 1.5 GB video triggers jetsam.
- The DB row is written only after the hash exists; files orphaned by a crash between the two are
  swept at launch ([09](09-diagnostics.md)).

## File layout

- `<AppSupport>/media/<projectID>/<sessionID>/<captureID>.<ext>`
- `FileProtectionType.completeUnlessOpen` per file ([07](07-security.md) explains why not AES-GCM).
- `media/` marked `isExcludedFromBackup` — R2 is the source of truth.
- DB stores relative paths.

## Pre-record buffer (later phase)

Keep the last 30 seconds so pressing record also saves what came before.

- **Never hold raw sample buffers in RAM** — 30 s of uncompressed 4K is multiple GB.
- `AVAssetWriter` writes 3-second segments to `<Caches>/prebuffer/`; keep a ring of `segmentCount`.
- On record: stop the ring, continue into a new segment, join with `AVMutableComposition` +
  `AVAssetExportSession`.
- Off by default; disables itself below `minBatteryLevel`. First to cut.

## Constants

```swift
enum CaptureConstants {
    static let photoQualityPrioritization: AVCapturePhotoOutput.QualityPrioritization = .balanced
    static let videoBitrate: Int = 8_000_000
    static let maxVideoDuration: TimeInterval = 600
    static let locationStaleAfter: TimeInterval = 120
    static let minFreeDiskBytesForVideo: Int64 = 500 * 1024 * 1024
}

enum PreRecordConstants {
    static let segmentDuration: TimeInterval = 3
    static let segmentCount: Int = 11
    static let minBatteryLevel: Float = 0.20
}

enum HashConstants {
    static let streamingChunkBytes: Int = 1_048_576
}
```

## Known risks

| Risk | Handling |
|---|---|
| Disk fills mid-recording | Check free space first; below threshold, block video and state the remainder |
| Thermal throttling | `.serious` → lower bitrate; `.critical` → stop deliberately |
| Denied permissions | Camera/mic/location handled separately, never one combined alert |
| Rotation | Preview transform must match writer transform, or exported video is rotated 90° and only shows up in the PDF |

## Definition of done

- 50 consecutive photos: flat memory, no dropped preview frames.
- 3-minute 1080p: plays back, hash reproduces, metadata complete.
- Incoming call mid-recording: file finalized, `uploadState = .pending`.
- Airplane mode + denied location: capture completes, `latitude == nil`.
- Zero warnings.

## Tests

| Test | Kind |
|---|---|
| `sha256` matches known vectors and `shasum -a 256` on a 200 MB file | unit |
| State machine rejects `startRecording` during `capturingPhoto` | unit, no camera |
| `interrupted` while `recording` finalizes exactly once | unit, mock session |
| Location older than `locationStaleAfter` yields `nil` | unit, injected clock |
| Ring buffer retains `segmentCount`, evicts oldest | unit, fake filesystem |
| Record + finalize + hash on device | manual |

State machine and ring buffer tests run without a camera via `protocol CaptureSessionControlling`.
