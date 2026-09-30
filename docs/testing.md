# Testing strategy

Libraries and why: [ADR 0006](adr/0006-test-libraries.md). Per-feature test lists live in each
feature spec's **Tests** section; this page sets the rules they follow.

## 1. What is tested where

| Layer | Target | Tool | What |
|---|---|---|---|
| Domain | `Packages/Domain/Tests` | Swift Testing | Every use case and pure domain service; no device, no frameworks |
| DataLayer | `Packages/DataLayer/Tests` | Swift Testing | Mappers (DTO ↔ entity), repository impls over in-memory SwiftData |
| Data sources | `Packages/<Name>/Tests` | Swift Testing | `UploadKit` state machine with `MockTransport`, `Realtime` decoding, `Reporting` layout |
| Presentation | `SiteLogTests` | Swift Testing + `FactoryTesting` | View models against fake use cases |
| Screens | `SiteLogTests/Snapshots` | swift-snapshot-testing | Each screen: light, dark, `accessibility3` Dynamic Type |
| Flows | `SiteLogUITests` | XCUITest | Smoke paths only: unlock → projects → capture → report |
| Backend | `Backend/test` | vitest | See [14](feature-docs/03-backend.md#12-done-and-tests) |

## 2. Rules

1. Scoped: a change runs the tests of the package it touched plus `Domain`, not the full suite.
2. No real network, clock, camera or Bluetooth in unit tests; inject `Clock`, `UploadTransport`,
   `CaptureSessionControlling`, `RandomNumberGenerator` ([00](feature-docs/00-overview.md#44-composition-root-factory)).
3. Every Factory override happens inside `@Suite(.container)`, so tests never leak registrations.
4. A bug fix lands with the test that would have caught it.
5. Snapshot references are recorded on one pinned simulator (iPhone 17 Pro, the CI OS version);
   re-record only in a commit that says why.

## 3. Examples

```swift
import FactoryTesting
import Testing
@testable import SiteLog

@Suite(.container)
struct LockViewModelTests {
    @Test func unlockSucceeds() async {
        Container.shared.biometricAuthenticator { AlwaysUnlocks() }
        #expect(await LockViewModel().unlockTapped())
    }
}
```

```swift
import SnapshotTesting
import SwiftUI
import Testing
@testable import SiteLog

@MainActor
struct LockViewSnapshotTests {
    @Test(arguments: [ColorScheme.light, .dark])
    func lockScreen(scheme: ColorScheme) {
        let view = LockView().environment(\.colorScheme, scheme)
        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }
}
```

## 4. Coverage targets

| Scope | Line coverage |
|---|---|
| `Domain` | ≥ 90% |
| `UploadKit`, sync engine | ≥ 85% |
| `DataLayer` | ≥ 70% |
| View models | ≥ 70% |
| Views | Snapshot per screen, no line target |

CI reports coverage per package; a PR that lowers a target fails the check
([17](feature-docs/05-platform.md#17-cicd-and-testflight)).
