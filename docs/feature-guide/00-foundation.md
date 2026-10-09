# F00 — Foundation

<dl><dd>

- F00 · 26h (8h done) · step-by-step guide with full, tested code.

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [0. Entry point (done)](#0-entry-point-done)
4. [1. Layer folders, Factory DI, AppClock](#1-layer-folders-factory-di-appclock)
5. [2. Fastlane test lane, PR checks](#2-fastlane-test-lane-pr-checks)
6. [3. CI guards](#3-ci-guards)
7. [4. DesignSystem tests](#4-designsystem-tests)
8. [Feature done](#feature-done)

</dd></dl>

## Overview

<dl><dd>

- **Goal:** what every feature builds on — layer folders, DI, CI, DesignSystem.
- **Demo:** the app builds with zero warnings, CI is green, the DesignSystem gallery snapshot passes.
- **Specs:** [00-overview](../feature-docs/00-overview.md) (architecture, DI), [05-platform](../feature-docs/05-platform.md) (testing, CI).
- **Already done:** entry point and tooling; DesignSystem tokens and components (built with the UI skeleton, 2026-10-08).
- **Verified:** all code below builds with zero warnings and passes its tests on iPhone 17 Pro (iOS 26.4); `fastlane test` passes.
- **How to use:** try each file from its hints first; open **Code** only to check or when stuck.
- **File tags:** <b class="tag-new">New</b> create the file · <b class="tag-edit">Edit</b> change only the part shown · <b class="tag-replace">Replace</b> overwrite the whole file · <b class="tag-check">Check</b> already in the repo, compare only.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| 0 | Tooling | 8h | done | Xcode project, XcodeGen, SwiftLint, hot reload, entry point |
| [1](#1-layer-folders-factory-di-appclock) | Architecture | 6h | not start | Layer folders, Factory DI, `AppClock`, test libraries |
| [2](#2-fastlane-test-lane-pr-checks) | CI | 5h | not start | Fastlane `test` lane, GitHub Actions PR checks |
| [3](#3-ci-guards) | CI | 4h | not start | CI guards: no `print(`, layer rules, secret scan, strict build |
| [4](#4-designsystem-tests) | Tests | 3h | not start | Hex test, `DSGallery`, snapshot test |

- Order: step 1 first (every feature needs DI). F01 can start right after step 1; steps 2–4 any time.

</dd></dl>

## Target structure

<dl><dd>

```text
site-log-ios/
├── Gemfile                                   # 2
├── fastlane/Appfile, Fastfile                # 2
├── .github/workflows/pr-checks.yml           # 2 + 3
├── Tools/CI/                                 # 3: check-no-print, check-imports, build-strict
├── project.yml                               # 1: DesignSystem, Factory, SnapshotTesting
├── Packages/DesignSystem/                    # done: Tokens/, Components/; 4: DSGallery + tests
├── SiteLog/
│   ├── App/AppDependencies.swift             # 1 (clock) → F01 (access)
│   ├── Core/Helper/Clock/                    # 1: AppClock, SystemClock
│   └── Data/Fakes/                           # every feature: in-memory repositories
└── SiteLogTests/
    ├── SiteLogTests.swift                    # 1: FixedClock + Factory test
    ├── Core/Helper/Clock/SystemClockTests.swift   # 1: mirrors SiteLog/Core/Helper/Clock/
    └── Snapshots/DesignSystemSnapshotTests.swift  # 4
```

<details open>
<summary><strong>Adding files</strong></summary>
<dl><dd>

| Editor | New Swift file |
|---|---|
| Xcode | Right-click the folder → **New Empty File**; nothing else (`SiteLog/` is a synced folder) |
| VS Code | Explorer → right-click → **New File…**; SweetPad regenerates the project |
| DesignSystem | Files under `Packages/DesignSystem/Sources` are picked up by SPM in both editors |

</dd></dl>
</details>

</dd></dl>

## 0. Entry point (done)

<dl><dd>

| # | Runs | File |
|---|---|---|
| 1 | iOS creates `SiteLogApp`; `@UIApplicationDelegateAdaptor` creates `AppDelegate` | `App/SiteLogApp.swift` |
| 2 | `didFinishLaunching` logs “App Launched” (Firebase goes first here in F12) | `App/AppDelegate.swift` |
| 3 | `RootView` shows `StartupView` while state is `.running` | `Presentation/Root/RootView.swift` |
| 4 | `StartupViewModel.onAppear()` runs `StartupSequence`, each step guarded and logged | `App/Startup/` |
| 5 | `.ready` → access flow (F01) → `MainTabView`; `.failed` → error + Try again | `Presentation/Access/Startup/` |

- Try the failure screen: pass `TestFailStartupStep()` in `RootView`’s `StartupSequence(steps:)`, run, then remove it.

</dd></dl>

## 1. Layer folders, Factory DI, AppClock

<dl><dd>

- **Goal:** layer folders in the app target, one composition root (Factory), an injectable clock, test libraries ready.
- **Why:** [D01](../feature-docs/00-overview.md#d01--factory-for-dependency-injection), [D06](../feature-docs/00-overview.md#d06--test-libraries).

<details open>
<summary><strong>1.1 project.yml — add libraries</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-edit">Edit</b> · `project.yml` → `packages:` *(add under `Inject`)*

<b>Explain</b> · Adds the local DesignSystem package and two libraries: Factory (DI) and swift-snapshot-testing.

<b>Hint</b>

- Three entries under `packages:`: the local `DesignSystem` path, Factory, swift-snapshot-testing.
- Use `from:` versions so SPM can take compatible updates.

<details>
<summary><b>Code</b></summary>

```yaml
  DesignSystem:
    path: Packages/DesignSystem
  Factory:
    url: https://github.com/hmlongco/Factory
    from: 3.4.1
  SnapshotTesting:
    url: https://github.com/pointfreeco/swift-snapshot-testing
    from: 1.19.6
```

</details>

---

<b>File</b> · <b class="tag-edit">Edit</b> · `project.yml` → `targets.SiteLog.dependencies` *(add at the end)*

<b>Explain</b> · Lets the app target use DesignSystem and FactoryKit.

<b>Hint</b>

- The app target needs `DesignSystem` and the `FactoryKit` product of Factory.

<details>
<summary><b>Code</b></summary>

```yaml
      - package: DesignSystem
      - package: Factory
        product: FactoryKit
```

</details>

---

<b>File</b> · <b class="tag-edit">Edit</b> · `project.yml` → `targets.SiteLogTests` *(replace its `dependencies` and `settings`)*

<b>Explain</b> · Lets the tests use the app, FactoryTesting and SnapshotTesting.

<b>Hint</b>

- Tests depend on the app target, `FactoryTesting` and `SnapshotTesting`.
- Set `SWIFT_VERSION` to 6.0, like the app.

<details>
<summary><b>Code</b></summary>

```yaml
    dependencies:
      - target: SiteLog
      - package: Factory
        product: FactoryTesting
      - package: SnapshotTesting
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: app.dd.SiteLogTests
        SWIFT_VERSION: "6.0"          # was 5.0
```

</details>

| Editor | Then |
|---|---|
| Xcode | Close the project → `xcodegen generate` in Terminal → reopen |
| VS Code | Save `project.yml`; run `xcodegen generate` in the terminal |

</dd></dl>
</details>

<details open>
<summary><strong>1.2 Layer folders + DesignSystem package</strong></summary>
<dl><dd>

- Layers are folders, not packages ([00-overview §4](../feature-docs/00-overview.md#4-architecture)); the one exception is `DesignSystem`.
- The folders `SiteLog/Domain/`, `SiteLog/Data/` already exist; delete a folder's `.gitkeep` when you add its first file.
- `Packages/DesignSystem/Sources/DesignSystem/DesignSystem.swift` (Xcode template): replace its content with `public enum DesignSystem {}` so the package still builds without `print`; delete it once the tokens exist (already done).

| Rule | Why |
|---|---|
| Types in `Domain/` and `Data/` are `nonisolated` | The app target defaults to `MainActor`; these types also run on background actors |
| No `public`, no `import Domain` | One module: everything is visible already |
| Layer rules are checked by `Tools/CI/check-imports.sh` (step 3) | The compiler no longer stops a view from using a `Data/` type |
| `DesignSystem` is a package: `public` API, `import DesignSystem` | UI only; the compiler keeps it free of `Domain` and app code |

<b>File</b> · <b class="tag-check">Check</b> · `Packages/DesignSystem/Package.swift`

<b>Explain</b> · Manifest of the DesignSystem package: one library and its test target.

<b>Hint</b>

- One `.library` product and one `.target` named `DesignSystem`, platform iOS 18.
- Add a `.testTarget` `DesignSystemTests` that depends on it.
- Enable the `ApproachableConcurrency` upcoming feature on both targets.

<details>
<summary><b>Code</b></summary>

```swift
// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]
        ),
    ],
    targets: [
        // Tokens and components only; knows nothing about Domain or features
        .target(
            name: "DesignSystem",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ]
)
```

</details>

</dd></dl>
</details>

<details open>
<summary><strong>1.3 AppClock</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Core/Helper/Clock/AppClock.swift`

<b>Explain</b> · The app’s clock as a protocol: `now` for timestamps, `uptime` for durations; tests swap in a fixed clock. In Core, not Domain: only Data, DataSources and Presentation need time.

<b>Hint</b>

- `nonisolated protocol … : Sendable`, so any actor can read it.
- Two read-only requirements: `now: Date` and `uptime: ContinuousClock.Instant`.

<details>
<summary><b>Code</b></summary>

```swift
import Foundation

// The app's clock, injected everywhere time matters, so tests can control time.
// Named AppClock so it does not clash with Swift's built-in `Clock` protocol.
nonisolated protocol AppClock: Sendable {
    // Wall-clock time: timestamps saved with records (createdAt, capturedAt)
    var now: Date { get }
    // Monotonic time: measuring durations; never jumps when the user changes the time
    var uptime: ContinuousClock.Instant { get }
}
```

</details>

---

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Core/Helper/Clock/SystemClock.swift`

<b>Explain</b> · The real `AppClock` used by the running app.

<b>Hint</b>

- A `nonisolated struct` that conforms to `AppClock`.
- `now` returns `Date()`; `uptime` returns `ContinuousClock.now`.

<details>
<summary><b>Code</b></summary>

```swift
import Foundation

// The real clock used by the running app.
nonisolated struct SystemClock: AppClock {
    var now: Date {
        return Date()
    }

    var uptime: ContinuousClock.Instant {
        return ContinuousClock.now
    }
}
```

</details>

---

<b>File</b> · <b class="tag-new">New</b> · `SiteLogTests/Core/Helper/Clock/SystemClockTests.swift`

<b>Explain</b> · Checks that `SystemClock.uptime` moves forward.

<b>Hint</b>

- Read `uptime`, wait ~10 ms with `Task.sleep`, read it again.
- `#expect` the second value is greater.

<details>
<summary><b>Code</b></summary>

```swift
import Foundation
import Testing
@testable import SiteLog

struct SystemClockTests {
    @Test func uptimeMovesForward() async throws {
        let clock = SystemClock()
        let first = clock.uptime

        try await Task.sleep(for: .milliseconds(10))

        let second = clock.uptime
        #expect(second > first)
    }
}
```

</details>

</dd></dl>
</details>

<details open>
<summary><strong>1.4 Composition root</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-replace">Replace</b> · `SiteLog/App/AppDependencies.swift` *(F00 version; F01 adds Access)*

<b>Explain</b> · Composition root: the one place that registers which implementation backs each protocol (Factory).

<b>Hint</b>

- `import FactoryKit`, then `extension Container`.
- One `Factory<any AppClock>` named `clock` that builds `SystemClock()`, scoped `.singleton`.

<details>
<summary><b>Code</b></summary>

```swift
import FactoryKit

// Composition root: the only place that knows which implementation backs each protocol.
// Data sources and stateful services are .singleton; use cases are created fresh (unscoped).
extension Container {
    // MARK: - Shared services

    var clock: Factory<any AppClock> {
        self { SystemClock() }.singleton
    }
}
```

</details>

</dd></dl>
</details>

<details open>
<summary><strong>1.5 First Factory test</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-replace">Replace</b> · `SiteLogTests/SiteLogTests.swift`

<b>Explain</b> · First Factory test: swaps the real clock for a fixed one.

<b>Hint</b>

- Write `FixedClock: AppClock` with stored `now` and `uptime`.
- Mark the suite `@Suite(.container)` so each test gets a fresh container.
- Register `FixedClock` on `Container.shared.clock`, resolve it, `#expect` the fixed date.

<details>
<summary><b>Code</b></summary>

```swift
import FactoryKit
import FactoryTesting
import Foundation
import Testing
@testable import SiteLog

// A clock that always returns the same time, so tests are repeatable
struct FixedClock: AppClock {
    let now: Date
    let uptime: ContinuousClock.Instant
}

// .container gives each test its own fresh Factory container
@Suite(.container)
struct AppDependenciesTests {
    @Test func clockCanBeReplacedInTests() {
        let fixedDate = Date(timeIntervalSince1970: 0)
        Container.shared.clock.register {
            FixedClock(now: fixedDate, uptime: ContinuousClock.now)
        }

        let clock = Container.shared.clock()

        #expect(clock.now == fixedDate)
    }
}
```

</details>

</dd></dl>
</details>

<details open>
<summary><strong>1.6 Check</strong></summary>
<dl><dd>

| Step | Expect |
|---|---|
| ⌘B (Xcode) or SweetPad Build | Zero warnings |
| ⌘U | `clockCanBeReplacedInTests` and `uptimeMovesForward` pass |

</dd></dl>
</details>

</dd></dl>

## 2. Fastlane test lane, PR checks

<dl><dd>

- **Goal:** one command (`bundle exec fastlane test`) runs the `DesignSystem` package tests and the app tests; GitHub runs it on every PR.
- **Spec:** [05 §17](../feature-docs/05-platform.md#17-cicd-and-testflight).

![CI/CD pipeline: guards and lint, then build, then fastlane test; a v* tag runs fastlane beta](../images/ci-cd-pipeline.svg)

<details open>
<summary><strong>2.1 Files</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `Gemfile`

<b>Explain</b> · Pins the fastlane version so `bundle exec fastlane` runs the same everywhere.

<b>Hint</b>

- `source "https://rubygems.org"` plus one pinned `gem "fastlane"` line.

<details>
<summary><b>Code</b></summary>

```ruby
source "https://rubygems.org"

# Pinned so every Mac and the CI runner run the same Fastlane
gem "fastlane", "~> 2.228"
```

</details>

---

<b>File</b> · <b class="tag-new">New</b> · `fastlane/Appfile`

<b>Explain</b> · App bundle id for fastlane.

<b>Hint</b>

- One line: `app_identifier` with the app bundle id.

<details>
<summary><b>Code</b></summary>

```ruby
# Bundle id of the app; signing comes from the App Store Connect API key (F04)
app_identifier("app.dd.site.log")
```

</details>

---

<b>File</b> · <b class="tag-new">New</b> · `fastlane/Fastfile`

<b>Explain</b> · fastlane lanes; `test` runs the unit and snapshot tests exactly like CI.

<b>Hint</b>

- Pin one simulator (name + OS) so snapshots compare the same pixels everywhere.
- Lane `test`: `xcodegen generate` → `xcodebuild test` for each package → `run_tests` for `SiteLogTests`.
- Write DerivedData and results under `build/`.

<details>
<summary><b>Code</b></summary>

```ruby
# Lanes for SiteLog. Run from the repo root: bundle exec fastlane <lane>
# Spec: docs/feature-docs/05-platform.md, section 17.

default_platform(:ios)

# One pinned simulator, so snapshot tests compare the same pixels everywhere
SIMULATOR_NAME = "iPhone 17 Pro"
SIMULATOR_OS = "26.4"
DESTINATION = "platform=iOS Simulator,name=#{SIMULATOR_NAME},OS=#{SIMULATOR_OS}"

# Local packages, tested one by one so a package never leans on the app
PACKAGES = ["DesignSystem"]

# Fastlane runs inside fastlane/, so the repo root is one level up
ROOT = File.expand_path("..", __dir__)

# Build output stays in build/ (git-ignored and excluded from SwiftLint)
DERIVED_DATA = File.join(ROOT, "build", "DerivedData")

platform :ios do
  desc "Generate the project, test every package, then test the app"
  lane :test do
    # 1. The .xcodeproj must match project.yml
    sh("cd '#{ROOT}' && xcodegen generate")

    # 2. Each package on its own, with code coverage
    PACKAGES.each do |package|
      package_dir = File.join(ROOT, "Packages", package)
      sh(
        "cd '#{package_dir}' && " \
        "xcodebuild test -scheme #{package} -destination '#{DESTINATION}' " \
        "-derivedDataPath '#{DERIVED_DATA}' -enableCodeCoverage YES -quiet"
      )
    end

    # 3. App unit + snapshot tests (UI tests run nightly, not per PR)
    run_tests(
      project: File.join(ROOT, "SiteLog.xcodeproj"),
      scheme: "SiteLog",
      device: "#{SIMULATOR_NAME} (#{SIMULATOR_OS})",
      only_testing: ["SiteLogTests"],
      derived_data_path: DERIVED_DATA,
      code_coverage: true,
      output_directory: File.join(ROOT, "build", "test-output")
    )
  end
end
```

</details>

---

<b>File</b> · <b class="tag-edit">Edit</b> · `.swiftlint.yml` → `excluded:` *(add one line)*

<b>Explain</b> · Keeps SwiftLint out of Fastlane’s build output.

<b>Hint</b>

- Add `build` to `excluded` so SwiftLint skips Fastlane output.

<details>
<summary><b>Code</b></summary>

```yaml
  - build      # Fastlane writes DerivedData here
```

</details>

</dd></dl>
</details>

<details open>
<summary><strong>2.2 Workflow (lint + test)</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `.github/workflows/pr-checks.yml` *(step 2 version)*

<b>Explain</b> · GitHub Actions workflow run on every pull request: lint and tests.

<b>Hint</b>

- Run on `pull_request` and pushes to `main`; cancel older runs of the same branch.
- Job `lint`: SwiftLint `--strict` in the official container on Ubuntu.
- Job `test` on the self-hosted Mac, after `lint`: `bundle install` → `bundle exec fastlane test`.

<details>
<summary><b>Code</b></summary>

```yaml
# Runs on every PR and every push to main. Spec: docs/feature-docs/05-platform.md §17.
name: PR checks

on:
  pull_request:
  push:
    branches: [main]

# A newer push to the same branch cancels the older run
concurrency:
  group: pr-checks-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint:
    runs-on: ubuntu-latest
    container: ghcr.io/realm/swiftlint:0.65.1
    steps:
      - uses: actions/checkout@v4
      - name: SwiftLint (warnings fail)
        run: swiftlint --strict

  # Builds and tests on the self-hosted development Mac
  test:
    runs-on: [self-hosted, macOS]
    needs: [lint]
    steps:
      - uses: actions/checkout@v4
      - name: Install gems
        run: bundle install
      - name: Fastlane test
        run: bundle exec fastlane test
```

</details>

</dd></dl>
</details>

<details open>
<summary><strong>2.3 Self-hosted runner (your Mac, once)</strong></summary>
<dl><dd>

| Step | Action |
|---|---|
| 1 | GitHub repo → **Settings → Actions → Runners → New self-hosted runner** → macOS, ARM64 |
| 2 | Run the shown `config.sh` command in a folder outside the repo; keep the default labels (`self-hosted`, `macOS`) |
| 3 | Start it: `./run.sh` (or `./svc.sh install && ./svc.sh start` to run at login) |
| 4 | Private repo only: a public repo would run strangers’ PR code on your Mac |

</dd></dl>
</details>

<details open>
<summary><strong>2.4 Check</strong></summary>
<dl><dd>

| Step | Expect |
|---|---|
| `bundle install` then `bundle exec fastlane test` | “Test Succeeded”, “fastlane.tools finished successfully” |
| Open a PR | **lint** and **test** jobs green |

</dd></dl>
</details>

</dd></dl>

## 3. CI guards

<dl><dd>

- **Goal:** rules that reviews forget are checked by machine: no `print(`, layer rules, secrets, the app builds with warnings as errors.
- Make each script executable once: `chmod +x Tools/CI/*.sh`.

<b>File</b> · <b class="tag-new">New</b> · `Tools/CI/check-no-print.sh`

<b>Explain</b> · Fails CI when app code uses `print(`; logging goes through `AppLogger`.

<b>Hint</b>

- `grep` for `print(` in `SiteLog`, `SiteLogTests`, `Packages`; ignore `.build`.
- Matches → print them and `exit 1`; none → `OK`.

<details>
<summary><b>Code</b></summary>

```bash
#!/usr/bin/env bash
# Fails when any Swift file in the app or packages calls print(.
# Rule: log with AppLogger (os.Logger), never print.
set -euo pipefail

# grep exits 1 when nothing matches, which is the good case here
matches=$(grep -rnE '(^|[^A-Za-z_.])print\(' SiteLog SiteLogTests Packages --include='*.swift' --exclude-dir='.build' || true)

if [ -n "$matches" ]; then
  echo "print( is not allowed, use AppLogger instead:"
  echo "$matches"
  exit 1
fi

echo "OK: no print( calls"
```

</details>

---

<b>File</b> · <b class="tag-new">New</b> · `Tools/CI/check-imports.sh`

<b>Explain</b> · Fails CI when a layer uses one it must not, e.g. a view using a `Data/` type.

<b>Hint</b>

- Rule 1: every `import` in `Domain/` must be `Foundation`.
- Rules 2–3: collect type names declared in `Data/`, `DataSources/` and `Core/`; grep them as whole words where they are banned.
- Rule 4: `Presentation/` never imports SwiftData or uses `ModelContext` / `URLSession`.

<details>
<summary><b>Code</b></summary>

```bash
#!/usr/bin/env bash
# Enforces the layer rules in docs/feature-docs/00-overview.md §4.2.
# Layers are folders in one target, so the compiler cannot stop a wrong reference: this script does.
set -euo pipefail

failed=0

# Rule 1: Domain imports Foundation only
domain_imports=$(grep -rhE '^[[:space:]]*import ' SiteLog/Domain --include='*.swift' | sed -E 's/^[[:space:]]*//' | sort -u | grep -vE '^import Foundation$' || true)
if [ -n "$domain_imports" ]; then
  echo "Domain may import Foundation only. Found:"
  echo "$domain_imports"
  failed=1
fi

# Rule 2: Presentation and Domain never use a type declared in Data/ or DataSources/
# Step 1: collect the name of every type declared there
data_types=$(grep -rhoE '(class|struct|enum|actor|protocol)[[:space:]]+[A-Z][A-Za-z0-9_]*' SiteLog/Data SiteLog/DataSources --include='*.swift' 2>/dev/null | awk '{print $2}' | sort -u || true)
# Step 2: look for each name as a whole word in Presentation and Domain
for type_name in $data_types; do
  uses=$(grep -rnw "$type_name" SiteLog/Presentation SiteLog/Domain --include='*.swift' || true)
  if [ -n "$uses" ]; then
    echo "Presentation and Domain may not use $type_name (declared in Data). Found:"
    echo "$uses"
    failed=1
  fi
done

# Rule 3: Domain never uses a type declared in Core/ (Core is for the outer layers)
core_types=$(grep -rhoE '(class|struct|enum|actor|protocol)[[:space:]]+[A-Z][A-Za-z0-9_]*' SiteLog/Core --include='*.swift' 2>/dev/null | awk '{print $2}' | sort -u || true)
for type_name in $core_types; do
  uses=$(grep -rnw "$type_name" SiteLog/Domain --include='*.swift' || true)
  if [ -n "$uses" ]; then
    echo "Domain may not use $type_name (declared in Core). Found:"
    echo "$uses"
    failed=1
  fi
done

# Rule 4: Presentation never touches storage or the network directly
direct_access=$(grep -rnE '^[[:space:]]*import (SwiftData|CoreData)$|ModelContext|URLSession' SiteLog/Presentation --include='*.swift' || true)
if [ -n "$direct_access" ]; then
  echo "Presentation may not use SwiftData, ModelContext or URLSession. Found:"
  echo "$direct_access"
  failed=1
fi

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "OK: layer rules"
```

</details>

---

<b>File</b> · <b class="tag-new">New</b> · `Tools/CI/build-strict.sh`

<b>Explain</b> · Builds the app with warnings treated as errors.

<b>Hint</b>

- `xcodegen generate`, then `xcodebuild clean build` into `build/`, output to a log file.
- Fail when the log has `warning:` lines from `SiteLog/` or `Packages/` files.

<details>
<summary><b>Code</b></summary>

```bash
#!/usr/bin/env bash
# Builds the app from clean and fails on any warning in our own code.
# Not SWIFT_TREAT_WARNINGS_AS_ERRORS: it clashes with the settings of remote packages.
set -euo pipefail

destination="platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4"
derived_data="$(pwd)/build/DerivedData-strict"
log="$(pwd)/build/strict-build.log"
mkdir -p build

# The .xcodeproj must match project.yml
xcodegen generate

# clean: an incremental build would not repeat warnings from unchanged files
xcodebuild clean build -project SiteLog.xcodeproj -scheme SiteLog -destination "$destination" \
  -derivedDataPath "$derived_data" -quiet > "$log" 2>&1

# Warnings (compiler + SwiftLint) in our files only (SiteLog/, Packages/), each listed once
warnings=$(grep -E '/(SiteLog|Packages)/[^:]+:[0-9]+:[0-9]+: warning: ' "$log" | sort -u || true)
if [ -n "$warnings" ]; then
  echo "Warnings are not allowed:"
  echo "$warnings"
  exit 1
fi

echo "OK: the app builds with zero warnings"
```

</details>

---

<b>File</b> · <b class="tag-replace">Replace</b> · `.github/workflows/pr-checks.yml` *(final: adds guards + build jobs)*

<b>Explain</b> · Final workflow: adds the guards job and the strict build before the tests.

<b>Hint</b>

- Add a `guards` job on Ubuntu: the two scripts + gitleaks (`fetch-depth: 0`).
- Add a `build` job on the Mac running `build-strict.sh`, after `guards` and `lint`.
- `test` now runs after `build`.

<details>
<summary><b>Code</b></summary>

```yaml
# Runs on every PR and every push to main. Spec: docs/feature-docs/05-platform.md §17.
name: PR checks

on:
  pull_request:
  push:
    branches: [main]

# A newer push to the same branch cancels the older run
concurrency:
  group: pr-checks-${{ github.ref }}
  cancel-in-progress: true

jobs:
  # Cheap checks on a hosted Linux runner
  guards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0   # gitleaks scans the whole history
      - name: No print(
        run: Tools/CI/check-no-print.sh
      - name: Layer imports
        run: Tools/CI/check-imports.sh
      - name: Secret scan
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  lint:
    runs-on: ubuntu-latest
    container: ghcr.io/realm/swiftlint:0.65.1
    steps:
      - uses: actions/checkout@v4
      - name: SwiftLint (warnings fail)
        run: swiftlint --strict

  # Builds and tests on the self-hosted development Mac
  build:
    runs-on: [self-hosted, macOS]
    needs: [guards, lint]
    steps:
      - uses: actions/checkout@v4
      - name: App builds, warnings as errors
        run: Tools/CI/build-strict.sh

  test:
    runs-on: [self-hosted, macOS]
    needs: [build]
    steps:
      - uses: actions/checkout@v4
      - name: Install gems
        run: bundle install
      - name: Fastlane test
        run: bundle exec fastlane test
```

</details>

<details open>
<summary><strong>3.1 Check</strong></summary>
<dl><dd>

| Step | Expect |
|---|---|
| Run each script from the repo root | `OK: …` |
| Add `print("x")` to any Swift file, run `check-no-print.sh` | Exit 1 with the file and line; then remove it |
| Add `import UIKit` to a Domain file, run `check-imports.sh` | Exit 1; then remove it |
| Add `struct Probe {}` in `SiteLog/Data/`, use `Probe()` in a view, run `check-imports.sh` | Exit 1; then delete both |
| Use `AppLogger` in a Domain file, run `check-imports.sh` | Exit 1; then remove it |

</dd></dl>
</details>

</dd></dl>

## 4. DesignSystem tests

<dl><dd>

- Tokens and components are already in `Packages/DesignSystem` (built with the UI skeleton).
- The feature is done, so its tests come now.

<b>File</b> · <b class="tag-replace">Replace</b> · `Packages/DesignSystem/Tests/DesignSystemTests/DesignSystemTests.swift`

<b>Explain</b> · Unit test for the hex colour helper behind `DSColor`.

<b>Hint</b>

- `@testable import DesignSystem` to reach the internal `UIColor(hex:)`.
- Decode `0xFFD400`, read the components with `getRed`, `#expect` 1, 0xD4/255, 0.

<details>
<summary><b>Code</b></summary>

```swift
import Testing
import UIKit
@testable import DesignSystem

struct DesignSystemTests {
    @Test func hexColourIsDecoded() {
        let color = UIColor(hex: 0xFFD400)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        #expect(red == 1)
        #expect(green == CGFloat(0xD4) / 255)
        #expect(blue == 0)
    }
}
```

</details>

---

<b>File</b> · <b class="tag-new">New</b> · `Packages/DesignSystem/Sources/DesignSystem/Components/DSGallery.swift`

<b>Explain</b> · Every DesignSystem component on one screen, for previews and the snapshot test.

<b>Hint</b>

- A `public struct DSGallery: View` stacking one of every component.
- Fill the screen with `DSColor.canvas`; add Light and Dark previews.

<details>
<summary><b>Code</b></summary>

```swift
import SwiftUI

// Every component on one screen: used by previews and by the snapshot test.
public struct DSGallery: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.regular) {
            DSSectionHeader(title: "Level 7", trailing: "3 open")

            VStack(spacing: 0) {
                DSListRow(title: "Riverside Tower B", subtitle: "District 7 · 14 open issues", showsChevron: true)
                DSListRow(title: "Lock after", value: "5 minutes", showsChevron: true)
            }

            HStack(spacing: DSSpacing.small) {
                DSChip(title: "All", isSelected: true, action: {})
                DSChip(title: "Has issues", isSelected: false, action: {})
                DSCountBadge(count: 2)
            }
            .padding(.horizontal, DSSpacing.regular)

            HStack(spacing: DSSpacing.regular) {
                ForEach(DSStatusMarker.Kind.allCases, id: \.self) { kind in
                    DSStatusMarker(kind: kind, text: String(describing: kind).capitalized)
                }
            }
            .padding(.horizontal, DSSpacing.regular)

            VStack(spacing: DSSpacing.small) {
                Button("Primary") {}
                    .buttonStyle(.ds(.primary))
                Button("Capture") {}
                    .buttonStyle(.ds(.hiVis))
                Button("Secondary") {}
                    .buttonStyle(.ds(.secondary))
                Button("Ghost") {}
                    .buttonStyle(.ds(.ghost))
                Button("Danger") {}
                    .buttonStyle(.ds(.danger))
            }
            .padding(.horizontal, DSSpacing.regular)

            DSEmptyState(systemImage: "folder", title: "No projects yet", message: "Create a project to start.")
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, DSSpacing.regular)
        // Fill the whole screen, including behind the status bar
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DSColor.canvas.ignoresSafeArea())
    }
}

#Preview("Light") {
    DSGallery()
}

#Preview("Dark") {
    DSGallery()
        .preferredColorScheme(.dark)
}
```

</details>

---

<b>File</b> · <b class="tag-new">New</b> · `SiteLogTests/Snapshots/DesignSystemSnapshotTests.swift`

<b>Explain</b> · Snapshots `DSGallery` in light and dark; fails when a component’s look changes.

<b>Hint</b>

- `@MainActor` suite; `@Test(arguments:)` over light and dark.
- Host `DSGallery` in a `UIHostingController`, `assertSnapshot(…, as: .image(on: .iPhone13Pro))`.

<details>
<summary><b>Code</b></summary>

```swift
import DesignSystem
import SnapshotTesting
import SwiftUI
import Testing

// First run records the reference images and fails; run again and it passes.
// References live next to this file in __Snapshots__/ and are committed.
@MainActor
struct DesignSystemSnapshotTests {
    @Test(arguments: [ColorScheme.light, ColorScheme.dark])
    func gallery(scheme: ColorScheme) {
        let view = DSGallery()
            .environment(\.colorScheme, scheme)
        let controller = UIHostingController(rootView: view)

        assertSnapshot(of: controller, as: .image(on: .iPhone13Pro), named: "\(scheme)")
    }
}
```

</details>

<details open>
<summary><strong>4.1 Check</strong></summary>
<dl><dd>

| Step | Expect |
|---|---|
| Scheme `DesignSystem` → ⌘U | `hexColourIsDecoded` passes |
| ⌘U the first time | Snapshot test fails and records `__Snapshots__/…light.png`, `…dark.png` |
| ⌘U again | Passes; commit the two PNGs |

</dd></dl>
</details>

</dd></dl>

## Feature done

<dl><dd>

| Check | How |
|---|---|
| Zero warnings | ⌘B in Xcode; `Tools/CI/build-strict.sh` |
| All tests green | `bundle exec fastlane test` |
| CI green | PR shows guards, lint, build, test passing |
| Roadmap | F00 steps ticked |

</dd></dl>
