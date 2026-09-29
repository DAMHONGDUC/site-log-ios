# 18 — Push notifications & deep links

Module: `App/Notifications`, `App/DeepLinks`

Two ways for the outside world to bring the user to a specific place in the app. They share one
destination type so a push tap and a tapped URL behave identically.

## 1. Goal

- Tapping a notification opens the exact session or issue it is about.
- A tapped `sitelog://` URL does the same.
- A link that arrives during cold launch is not lost.

## 2. Scope

| In | Out |
|---|---|
| APNs registration, foreground banners | Rich notifications, notification actions |
| Custom-scheme deep links | Universal links (needs a domain, later) |
| One shared `DeepLink` destination type | Silent push as an upload trigger (rejected in [10](10-realtime-progress.md)) |
| Device token exposed to the app layer | Sending the token to the backend (needs [14](14-backend.md)) |

## 3. Deep link format

`sitelog://<route>/<id>`

| URL | Destination |
|---|---|
| `sitelog://session/42` | session 42 |
| `sitelog://issue/7` | issue 7 |

- Wrong scheme, unknown route, or missing id → ignored and logged, never a crash.
- The parser is pure and has no UI dependency.
- IDs are opaque strings; the parser never assumes a format.

## 4. Push payload

```json
{ "aps": { "alert": { "title": "Issue updated" } }, "deepLink": "sitelog://issue/42" }
```

- `deepLink` is optional; without it a tap just opens the app.
- The payload carries a destination only, never data the app then trusts. State comes from the
  local store ([04](04-upload-engine.md)).

## 4.1 Registration

```
launch → request authorization (once) → register with APNs → token → app layer
```

- Authorization is requested at a moment that makes sense to the user, not blindly at first launch
  once real onboarding exists.
- The token is logged truncated, never in full.
- Foreground: show banner and sound, so a notification is not silently swallowed.

## 5. Routing

```
URL / push tap ──→ DeepLink parser ──→ router (pending) ──→ view consumes and navigates
```

- The router **holds** the destination until a view consumes it. A cold-launch link arrives before
  any view exists; a fire-and-forget callback would lose it.
- Consuming clears it, so going back does not re-navigate.
- A destination that no longer exists (deleted issue) lands on a safe screen with a message.

## 6. Setup

1. Enable **Push Notifications** for `app.dd.site.log` in the developer portal.
2. Entitlement `aps-environment` is `development` in the project; distribution signing switches it
   to `production`.
3. Register the `sitelog` URL scheme and the `remote-notification` background mode.
4. Simulator: `xcrun simctl push booted app.dd.site.log payload.json`,
   `xcrun simctl openurl booted sitelog://session/42`.

## 7. Known risks

| Risk | Handling |
|---|---|
| A malicious app opens `sitelog://` with crafted ids | Parser treats ids as data; the destination re-checks access before showing anything ([07](07-security.md)) |
| Push for an account the device is no longer signed in to | Ignore when no session matches; never show cross-account content |
| Token changes | Treat the token as replaceable; re-send whenever it differs |
| Permission denied | App works fully without push; nothing may depend on it |

## 8. Definition of done

- `sitelog://session/42` from Safari and from `simctl` opens session 42.
- A notification tap opens the target with the app killed, backgrounded, and foregrounded.
- Garbage URLs and payloads are ignored with a log line and no crash.
- Denying notification permission leaves every feature working.

## 9. Tests

| Test | Kind |
|---|---|
| Parser accepts both routes, rejects wrong scheme / unknown route / missing id | unit, pure |
| Payload with and without `deepLink` | unit, pure |
| Router holds a link until consumed, then clears | unit |
| Unsupported URL leaves pending unchanged | unit |
| Cold-launch link survives until the first view appears | UI test |
