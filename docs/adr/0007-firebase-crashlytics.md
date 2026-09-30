# 0007 — Firebase Crashlytics for crash reporting

Status: Accepted · 2026-09-30 · Spec: [09](../feature-docs/05-platform.md#09-diagnostics-and-observability)

## Context

Field crashes on devices we never see must be symbolicated, grouped and alerted. Firebase is
already in the app for Auth.

## Decision

Firebase Crashlytics (firebase-ios-sdk 12.x), initialized first at launch. dSYMs upload from the
Fastlane release lane. Non-fatals are recorded with the same structured data as the log line.

## Rejected

| Option | Why not |
|---|---|
| Sentry | Second vendor and SDK next to Firebase |
| MetricKit / Xcode Organizer only | Delayed, TestFlight/App Store only, no custom keys or non-fatals |

## Consequences

- No user content or PII in custom keys; IDs only.
- The startup sequence must never block on Crashlytics ([00](../feature-docs/00-overview.md#45-startup-sequence)).
