# F14 — Push and deep links

<dl><dd>

- F14 · 11h · skeleton guide — full code is added when this feature starts.

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain — Deep link parser](#1-domain--deep-link-parser)
4. [2. View models — Notification permission and settings](#2-view-models--notification-permission-and-settings)
5. [3. Real data — Push and routing](#3-real-data--push-and-routing)
6. [Tests (after the feature works)](#tests-after-the-feature-works)
7. [Feature done](#feature-done)

</dd></dl>

## Overview

<dl><dd>

- **Goal:** Push and deep links end to end: Domain → fake data → view models → real data → tests.
- **Demo:** a push opens its target; `sitelog://` links work after cold launch.
- **Spec:** [18](../feature-docs/05-platform.md#18-push-notifications-and-deep-links)
- **Starts from:** the skeleton screens (~30% of Figma) that read `Core/Fakes/FakeData.swift`.
- **Fakes:** only in `SiteLog/Data/Fakes/`, registered in `AppDependencies`; the dev menu seeds / clears them through `FakeDevDataActions`.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--deep-link-parser) | Domain | 1h | not start | Deep link parser |
| [2](#2-view-models--notification-permission-and-settings) | View models | 2h | not start | Notification permission and settings |
| [3](#3-real-data--push-and-routing) | Real data | 8h | not start | Push and routing |

<details open>
<summary><strong>Order</strong></summary>
<dl><dd>

- Steps run top to bottom; the app runs after every step.
- Real data changes only registrations in `AppDependencies`, never views or view models.
- Tests come last, once the feature works end to end.

</dd></dl>
</details>

</dd></dl>

## Target structure

<dl><dd>

```text
SiteLog/
├── Domain/DeepLinks/DeepLink.swift      # 1: pure parser
├── App/AppDelegate.swift                # 3: push token
└── Presentation/Notifications/, DeepLinks/   # 2–3
```

</dd></dl>

## 1. Domain — Deep link parser

<dl><dd>

- No fake needed: the parser is pure and push uses `xcrun simctl push` in the Simulator.

| File | Holds |
|---|---|
| `Domain/DeepLinks/DeepLink.swift` | `sitelog://<route>/<id>`; ids are opaque data |

</dd></dl>

## 2. View models — Notification permission and settings

<dl><dd>

- **Goal:** permission prompt at the right moment; notification row in Settings.

#### Steps

<dl><dd>

1. Explain the benefit before the system prompt.

</dd></dl>

</dd></dl>

## 3. Real data — Push and routing

<dl><dd>

<details open>
<summary><strong>3.1 Push notifications</strong></summary>
<dl><dd>

- **Goal:** push that carries a destination only; works fully when denied.
- **Spec:** [18](../feature-docs/05-platform.md#18-push-notifications-and-deep-links)

| File | Holds |
|---|---|
| `project.yml` | Push capability, `aps-environment`, `remote-notification` background mode |
| `SiteLog/App/AppDelegate.swift` | Token registration (logged truncated), re-sent on change |

#### Steps

<dl><dd>

1. Ask for permission at a moment that makes sense, not at first launch.
2. Test: `xcrun simctl push booted app.dd.site.log payload.json`.

</dd></dl>
</details>

<details open>
<summary><strong>3.2 Deep links</strong></summary>
<dl><dd>

- **Goal:** `sitelog://<route>/<id>` parsed once, routed after cold launch.
- **Spec:** [18](../feature-docs/05-platform.md#18-push-notifications-and-deep-links)

| File | Holds |
|---|---|
| `Domain/DeepLinks/DeepLink.swift` | Pure parser; ids are opaque data |
| `Presentation/DeepLinks/DeepLinkRouter.swift` | Holds the destination until a view consumes it |

</dd></dl>

#### Steps

<dl><dd>

1. Add the `sitelog` URL scheme in `project.yml`.
2. Deleted target lands on a safe screen.
3. Test: `xcrun simctl openurl booted sitelog://session/42`.

</dd></dl>
</details>

</dd></dl>

</dd></dl>

## Tests (after the feature works)

<dl><dd>

**2. View models — Notification permission and settings**

- View model
- Snapshot

**3. Real data — Push and routing**

- Payload with / without `deepLink`
- Push for another account ignored
- Parser routes and rejections
- Router holds until consumed
- Cold-launch link survives (UI test)

</dd></dl>

## Feature done

<dl><dd>

| Check | How |
|---|---|
| Demo | Push opens the target; deep link from Safari |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F14 steps ticked |

</dd></dl>
