# 0005 — Kingfisher for remote images

Status: Accepted · 2026-09-30

## Context

On a second device, photos captured elsewhere are shown from R2 via presigned GET URLs. Lists show
hundreds of thumbnails; memory and disk caching, downsampling, cancellation and prefetching are
commodity problems.

## Decision

[Kingfisher](https://github.com/onevcat/Kingfisher) 8.x (`KFImage` in SwiftUI) with
`DownsamplingImageProcessor` to the cell size and a bounded disk cache. Local originals are always
read from disk with `CGImageSourceCreateThumbnailAtIndex`, never through Kingfisher.

## Rejected

| Option | Why not |
|---|---|
| `AsyncImage` | No disk cache, no downsampling, no prefetch |
| Nuke | Equally capable; Kingfisher is the more widely used choice |
| Hand-written cache | Commodity problem, no product value |

## Consequences

- Cache key must drop the presigned query string, or every URL refresh re-downloads the image.
- Cache is cleared on sign-out and account deletion ([08](../feature-docs/02-upload-sync.md#08-auth-and-sync)).
