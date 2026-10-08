# F15 — Accessibility and performance

- F15 · 14h · skeleton guide — full code is added when this feature starts.

## Contents

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Polish — Accessibility pass](#1-polish--accessibility-pass)
4. [2. Release — Budgets and feedback](#2-release--budgets-and-feedback)
5. [Tests (after the feature works)](#tests-after-the-feature-works)
6. [Feature done](#feature-done)

## Overview

- **Goal:** Accessibility and performance end to end: Domain → fake data → view models → real data → tests.
- **Demo:** VoiceOver walk unlock → projects → capture → report; every Instruments budget met.
- **Spec:** [19 Instruments](../feature-docs/05-platform.md#19-performance-profiling-with-instruments)
- **Starts from:** the skeleton screens (~30% of Figma) that read `Core/Fakes/FakeData.swift`.
- **Fakes:** only in `SiteLog/Data/Fakes/`, registered in `AppDependencies`; the dev menu seeds / clears them through `FakeDevDataActions`.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-polish--accessibility-pass) | Polish | 8h | not start | Accessibility pass |
| [2](#2-release--budgets-and-feedback) | Release | 6h | not start | Budgets and feedback |

### Order

- Steps run top to bottom; the app runs after every step.
- Real data changes only registrations in `AppDependencies`, never views or view models.
- Tests come last, once the feature works end to end.

## Target structure

```text
SiteLog/PrivacyInfo.xcprivacy    # 2
SiteLogTests/Snapshots/          # 1: accessibility3 per screen
```

## 1. Polish — Accessibility pass

- **Goal:** every screen readable with Dynamic Type, VoiceOver and high contrast.

| File | Holds |
|---|---|
| Every screen | Labels, traits, grouping, focus order |
| `SiteLogTests/Snapshots/` | `accessibility3` snapshot per screen |

#### Steps

1. VoiceOver walk: unlock → projects → capture → report.
2. Severity readable without colour (shapes already in `DSStatusMarker`).
3. Minimum 44 pt targets.

## 2. Release — Budgets and feedback

- **Goal:** Instruments budgets met, TestFlight feedback closed. Submission is in F16.
- **Spec:** [19](../feature-docs/05-platform.md#19-performance-profiling-with-instruments)

| File | Holds |
|---|---|
| `SiteLog/PrivacyInfo.xcprivacy` | Location, device ID, crash data declared |

#### Steps

1. Run scenarios 1–5 of 05 §19 on device, Release build; save traces.
2. Close every open TestFlight feedback item.

#### Done when

- Every budget met with a recorded trace
- No open TestFlight feedback

## Tests (after the feature works)

**1. Polish — Accessibility pass**

- Snapshots at `accessibility3`
- Xcode Accessibility Inspector audit clean

## Feature done

| Check | How |
|---|---|
| Demo | VoiceOver walk; budgets met with traces |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F15 steps ticked |
