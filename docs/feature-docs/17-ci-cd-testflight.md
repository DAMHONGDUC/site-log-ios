# 17 — CI/CD & TestFlight

Module: `fastlane/`, `.github/workflows/`

How a commit becomes a tester's build without anyone's laptop being involved.

## 1. Goal

- Every PR proves: lint clean, every package builds, unit tests pass.
- A tag becomes a TestFlight build with no manual Xcode step.
- No certificates or private keys stored in CI.

## 2. Scope

| In | Out |
|---|---|
| Fastlane lanes `test`, `beta`, `release` | Automatic App Store review submission |
| GitHub Actions for PR checks and TestFlight | Screenshot / metadata automation |
| Build number from TestFlight | Self-hosted runners (see [15](15-roadmap.md)) |
| Xcode-managed signing via App Store Connect API key | `match` certificate repo |

## 3. Lanes

| Lane | Does |
|---|---|
| `test` | `xcodegen`, `swift test` per package, then app unit tests (no UI tests) |
| `beta` | Release archive, upload to TestFlight, do not wait for processing |
| `release` | Same upload, wait for processing; review submission stays manual |

Every lane starts with `xcodegen` because `project.yml` is the source of truth
([xcodegen.md](../dev-docs/xcodegen.md)).

## 4. Workflows

| Workflow | Trigger | Runs |
|---|---|---|
| PR checks | PR, push to `main` | `swiftlint --strict`, lane `test` |
| TestFlight | tag `v*`, manual | lane `beta` |

- Concurrent runs of the same ref cancel the older one.
- TestFlight job runs in a protected GitHub environment holding the secrets.

## 5. Signing and versions

- **Signing** — Xcode-managed. `-allowProvisioningUpdates` plus the App Store Connect API key lets
  `xcodebuild` fetch or create distribution certs and profiles. Nothing to rotate in CI.
- **Build number** — latest TestFlight build + 1, passed as `CURRENT_PROJECT_VERSION`. Nothing is
  committed per release.
- **Marketing version** — `MARKETING_VERSION` in `project.yml`, bumped by hand.

## 6. Secrets

| Secret | Content |
|---|---|
| `ASC_KEY_ID` | API key ID |
| `ASC_ISSUER_ID` | Issuer ID |
| `ASC_KEY_CONTENT` | Base64 of the `.p8` |

- Stored only in the `testflight` environment, never in the repo, never echoed in logs.
- The `.p8` is written to a temp file for the build and deleted in `ensure`.
- Key role: App Manager, the minimum that can upload.

## 7. One-time setup

1. Create the App Store Connect API key, download the `.p8` once.
2. Create the app record `app.dd.site.log`.
3. Create the GitHub environment `testflight`, add the three secrets.
4. Release: `git tag v1.0.0 && git push origin v1.0.0`.

## 8. Known risks

| Risk | Handling |
|---|---|
| Secret leaks through a fork's PR | Secrets only in the `testflight` environment, never in PR workflows |
| Duplicate build number from two parallel runs | Release workflow is tag-only; tags are serialized by hand |
| Runner Xcode version drifts from local | Pin in the workflow once the first mismatch appears |
| CI depends on the network for `xcodegen`/gems | Acceptable; nothing here is offline-critical |

## 9. Definition of done

- A PR with a SwiftLint warning fails.
- A PR with a failing package test fails.
- Pushing `v0.0.1` produces a TestFlight build with no local action.
- The repo contains no `.p8`, no certificate, no profile.

## 10. Tests

| Test | Kind |
|---|---|
| `fastlane test` passes on a clean clone | manual, once per change to the lane |
| Dry run of `beta` against a throwaway app record | manual |
| gitleaks over the diff | CI (see [15](15-roadmap.md)) |
