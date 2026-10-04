# M0 — Scaffold

- M0 — Scaffold · 40h · step-by-step guide with full, tested code.

## Contents

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [P01 · Entry point (done)](#p01--entry-point-done)
4. [P02 · Layer folders, Factory DI, AppClock](#p02--layer-folders-factory-di-appclock)
5. [P03 · Fastlane test lane, PR checks](#p03--fastlane-test-lane-pr-checks)
6. [P04 · CI guards](#p04--ci-guards)
7. [P05 · DesignSystem tokens](#p05--designsystem-tokens)
8. [P06 · DesignSystem components](#p06--designsystem-components)
9. [P07 · Access flow on fakes](#p07--access-flow-on-fakes)
10. [Milestone done](#milestone-done)

## Overview

- **Goal:** a clean skeleton every later milestone builds on — layer folders, DI, CI, DesignSystem, access flow on fakes.
- **Demo:** the app builds with zero warnings, CI is green; DesignSystem and the access flow run on fakes.
- **Specs:** [00-overview](../feature-docs/00-overview.md) (architecture, DI), [05-platform](../feature-docs/05-platform.md) (testing, CI), [04 §07.2](../feature-docs/04-reporting-security.md) (app lock).
- **Verified:** all code below builds with zero warnings and passes its tests on iPhone 17 Pro (iOS 26.4); `fastlane test` passes.

| Part | Track | Hours | Status | What |
|---|---|---|---|---|
| P01 | `Logic` | 8h | done | Xcode project, XcodeGen, SwiftLint, hot reload, entry point |
| [P02](#p02--layer-folders-factory-di-appclock) | `Logic` | 6h | not start | Layer folders, Factory DI, `AppClock`, test libraries |
| [P03](#p03--fastlane-test-lane-pr-checks) | `Logic` | 5h | not start | Fastlane `test` lane, GitHub Actions PR checks |
| [P04](#p04--ci-guards) | `Logic` | 4h | not start | CI guards: no `print(`, layer rules, secret scan, strict build |
| [P05](#p05--designsystem-tokens) | `UI` | 5h | not start | DesignSystem tokens |
| [P06](#p06--designsystem-components) | `UI` | 6h | not start | DesignSystem components + snapshot test |
| [P07](#p07--access-flow-on-fakes) | `UI` | 6h | in progress | Access flow on fakes: A2, A1, A3, privacy overlay |

- Order: P02 first (everything needs it). Then UI (P05 → P06 → P07) and Logic (P03 → P04) alternate freely.

## Target structure

```text
site-log-ios/
├── Gemfile                                   # P03
├── fastlane/Appfile, Fastfile                # P03
├── .github/workflows/pr-checks.yml           # P03 + P04
├── Tools/CI/                                 # P04: check-no-print, check-imports, build-strict
├── project.yml                               # P02: DesignSystem, Factory, SnapshotTesting
├── Packages/DesignSystem/                    # P02: Swift package (UI only)
│   ├── Package.swift
│   ├── Sources/DesignSystem/
│   │   ├── Tokens/                           # P05: DSColor, DSFont, DSSpacing
│   │   └── Components/                       # P06: DSButtonStyle, DSListRow, DSSectionHeader, DSChip,
│   │                                         #      DSStatusMarker, DSCountBadge, DSEmptyState, DSGallery
│   └── Tests/DesignSystemTests/              # P05
├── SiteLog/
│   ├── App/
│   │   └── AppDependencies.swift             # P02 (clock) → P07 (access)
│   ├── Domain/
│   │   ├── Clock/AppClock.swift              # P02
│   │   └── Access/                           # P07: AccessSettings, PasscodeCheck, AccessRepository, AccessUseCases
│   ├── Data/Clock/SystemClock.swift          # P02
│   ├── Core/
│   │   ├── Fakes/InMemoryAccessRepository.swift   # P07
│   │   └── Helper/Logger/AppLogger.swift     # P07: nonisolated + access category
│   └── Presentation/
│       ├── Root/RootView.swift, RootViewModel.swift   # P07
│       └── Access/
│           ├── Startup/                      # done (P01)
│           ├── SignIn/                       # P07: A2
│           ├── FaceIDLock/                   # P07: A1
│           ├── PasscodeUnlock/               # P07: A3
│           └── PrivacyOverlay/               # P07
└── SiteLogTests/
    ├── SiteLogTests.swift                    # P02: FixedClock + Factory test
    ├── Data/SystemClockTests.swift           # P02
    ├── Access/PasscodeUnlockViewModelTests.swift  # P07
    └── Snapshots/DesignSystemSnapshotTests.swift  # P06
```

### Adding files

| Editor | New Swift file |
|---|---|
| Xcode | Right-click the folder → **New Empty File**; nothing else (`SiteLog/` is a synced folder) |
| VS Code | Explorer → right-click → **New File…**; SweetPad regenerates the project |
| DesignSystem | Files under `Packages/DesignSystem/Sources` are picked up by SPM in both editors |

## P01 · Entry point (done)

| # | Runs | File |
|---|---|---|
| 1 | iOS creates `SiteLogApp`; `@UIApplicationDelegateAdaptor` creates `AppDelegate` | `App/SiteLogApp.swift` |
| 2 | `didFinishLaunching` logs “App Launched” (Firebase goes first here in M5) | `App/AppDelegate.swift` |
| 3 | `RootView` shows `StartupView` while state is `.running` | `Presentation/Root/RootView.swift` |
| 4 | `StartupViewModel.onAppear()` runs `StartupSequence`, each step guarded and logged | `App/Startup/` |
| 5 | `.ready` → access flow (P07) → `MainTabView`; `.failed` → error + Try again | `Presentation/Access/Startup/` |

- Try the failure screen: pass `TestFailStartupStep()` in `RootView`’s `StartupSequence(steps:)`, run, then remove it.

## P02 · Layer folders, Factory DI, AppClock

- **Goal:** layer folders in the app target, one composition root (Factory), an injectable clock, test libraries ready.
- **Why:** [D01](../feature-docs/00-overview.md#d01--factory-for-dependency-injection), [D06](../feature-docs/00-overview.md#d06--test-libraries).

### 1. project.yml — add libraries

`project.yml → packages: (add under Inject)`

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

`project.yml → targets.SiteLog.dependencies (add)`

```yaml
      - package: DesignSystem
      - package: Factory
        product: FactoryKit
```

`project.yml → targets.SiteLogTests`

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

| Editor | Then |
|---|---|
| Xcode | Close the project → `xcodegen generate` in Terminal → reopen |
| VS Code | Save `project.yml`; run `xcodegen generate` in the terminal |

### 2. Layer folders + DesignSystem package

- Layers are folders, not packages ([00-overview §4](../feature-docs/00-overview.md#4-architecture)); the one exception is `DesignSystem`.
- The folders `SiteLog/Domain/`, `SiteLog/Data/` already exist; delete a folder's `.gitkeep` when you add its first file.
- `Packages/DesignSystem/Sources/DesignSystem/DesignSystem.swift` (Xcode template): replace its content with `public enum DesignSystem {}` so the package still builds without `print`; P05 deletes it.

| Rule | Why |
|---|---|
| Types in `Domain/` and `Data/` are `nonisolated` | The app target defaults to `MainActor`; these types also run on background actors |
| No `public`, no `import Domain` | One module: everything is visible already |
| Layer rules are checked by `Tools/CI/check-imports.sh` (P04) | The compiler no longer stops a view from using a `Data/` type |
| `DesignSystem` is a package: `public` API, `import DesignSystem` | UI only; the compiler keeps it free of `Domain` and app code |

`Packages/DesignSystem/Package.swift`

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

### 3. AppClock

`SiteLog/Domain/Clock/AppClock.swift`

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

`SiteLog/Data/Clock/SystemClock.swift`

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

`SiteLogTests/Data/SystemClockTests.swift`

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

### 4. Composition root

`SiteLog/App/AppDependencies.swift (P02 version; P07 adds Access)`

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

### 5. First Factory test

`SiteLogTests/SiteLogTests.swift (replace)`

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

### Check

| Step | Expect |
|---|---|
| ⌘B (Xcode) or SweetPad Build | Zero warnings |
| ⌘U | `clockCanBeReplacedInTests` and `uptimeMovesForward` pass |

## P03 · Fastlane test lane, PR checks

- **Goal:** one command (`bundle exec fastlane test`) runs the `DesignSystem` package tests and the app tests; GitHub runs it on every PR.
- **Spec:** [05 §17](../feature-docs/05-platform.md#17-cicd-and-testflight).

### 1. Files

`Gemfile`

```ruby
source "https://rubygems.org"

# Pinned so every Mac and the CI runner run the same Fastlane
gem "fastlane", "~> 2.228"
```

`fastlane/Appfile`

```ruby
# Bundle id of the app; signing comes from the App Store Connect API key (M2)
app_identifier("app.dd.site.log")
```

`fastlane/Fastfile`

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

`.swiftlint.yml → excluded (add)`

```yaml
  - build      # Fastlane writes DerivedData here
```

### 2. Workflow (lint + test)

`.github/workflows/pr-checks.yml (P03 version)`

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

### 3. Self-hosted runner (your Mac, once)

| Step | Action |
|---|---|
| 1 | GitHub repo → **Settings → Actions → Runners → New self-hosted runner** → macOS, ARM64 |
| 2 | Run the shown `config.sh` command in a folder outside the repo; keep the default labels (`self-hosted`, `macOS`) |
| 3 | Start it: `./run.sh` (or `./svc.sh install && ./svc.sh start` to run at login) |
| 4 | Private repo only: a public repo would run strangers’ PR code on your Mac |

### Check

| Step | Expect |
|---|---|
| `bundle install` then `bundle exec fastlane test` | “Test Succeeded”, “fastlane.tools finished successfully” |
| Open a PR | **lint** and **test** jobs green |

## P04 · CI guards

- **Goal:** rules that reviews forget are checked by machine: no `print(`, layer rules, secrets, the app builds with warnings as errors.
- Make each script executable once: `chmod +x Tools/CI/*.sh`.

`Tools/CI/check-no-print.sh`

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

`Tools/CI/check-imports.sh`

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

# Rule 3: Presentation never touches storage or the network directly
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

`Tools/CI/build-strict.sh`

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

`.github/workflows/pr-checks.yml (final: adds guards + build jobs)`

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

### Check

| Step | Expect |
|---|---|
| Run each script from the repo root | `OK: …` |
| Add `print("x")` to any Swift file, run `check-no-print.sh` | Exit 1 with the file and line; then remove it |
| Add `import UIKit` to a Domain file, run `check-imports.sh` | Exit 1; then remove it |
| Use `SystemClock()` in a view, run `check-imports.sh` | Exit 1; then remove it |

## P05 · DesignSystem tokens

- **Goal:** every colour, font and spacing value from the [Foundations board](../design/mockups/index.html) as Swift constants; views never type raw numbers or hex.
- Delete `DesignSystem.swift` (the P02 placeholder).
- Spacing names are words (`small`, `regular`…): SwiftLint rejects names under 3 characters.

`Packages/DesignSystem/Sources/DesignSystem/Tokens/DSColor.swift`

```swift
import SwiftUI
import UIKit

// Colour tokens from COLOR_TOKENS in docs/design/mockups/index.html.
// Each colour switches between its light and dark value by itself.
public enum DSColor {
    // MARK: Background
    // Screen background
    public static let canvas = dynamic(light: 0xFFFFFF, dark: 0x0F1011)
    // Docks, tab bar, sheets, alerts
    public static let raised = dynamic(light: 0xFFFFFF, dark: 0x18191B)
    // Text fields, search, segmented track, panels
    public static let fill = dynamic(light: 0xF3F2EF, dark: 0x232427)
    // Floor-plan canvas
    public static let plan = dynamic(light: 0xFBFAF7, dark: 0x1B1C1E)

    // MARK: Line
    // Row separators, dock and tab bar edge
    public static let hairline = dynamic(light: 0xE8E5E0, dark: 0x2C2D31)
    // Secondary-button border, dashed drop zones
    public static let lineStrong = dynamic(light: 0xCFCAC1, dark: 0x3F4045)

    // MARK: Text
    // Titles, body, primary button fill
    public static let textPrimary = dynamic(light: 0x16181B, dark: 0xF2F0EC)
    // Subtitles, meta, section counts
    public static let textSecondary = dynamic(light: 0x63676E, dark: 0xA4A7AD)
    // Placeholders, chevrons, disabled
    public static let textTertiary = dynamic(light: 0xA0A3A9, dark: 0x6E7278)
    // Text on primary (ink) fills
    public static let onPrimary = dynamic(light: 0xFFFFFF, dark: 0x16181B)

    // MARK: Accent (only the app mark, capture button and live-session dot)
    public static let hiVis = dynamic(light: 0xFFD400, dark: 0xFFD400)
    public static let onHiVis = dynamic(light: 0x1B1700, dark: 0x1B1700)

    // MARK: Severity and status
    public static let critical = dynamic(light: 0xD8342A, dark: 0xFF5B4F)
    public static let major = dynamic(light: 0xDD7A06, dark: 0xFFA43D)
    public static let minor = dynamic(light: 0x3E6FA8, dark: 0x80A9DC)
    public static let success = dynamic(light: 0x1D8454, dark: 0x43C287)
    // Waiting is never red
    public static let waiting = dynamic(light: 0x7E838B, dark: 0x8E939B)

    // Builds one Color that iOS redraws when light/dark mode changes
    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        let lightColor = UIColor(hex: light)
        let darkColor = UIColor(hex: dark)

        let uiColor = UIColor { traits in
            if traits.userInterfaceStyle == .dark {
                return darkColor
            } else {
                return lightColor
            }
        }

        return Color(uiColor: uiColor)
    }
}

extension UIColor {
    // 0xRRGGBB → UIColor
    convenience init(hex: UInt32) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
```

`Packages/DesignSystem/Sources/DesignSystem/Tokens/DSFont.swift`

```swift
import SwiftUI

// Type tokens from TYPE_TOKENS in the mockups.
// All are Dynamic Type text styles, so they grow with the user's text size setting.
public enum DSFont {
    // Top-level screen titles
    public static let largeTitle = Font.largeTitle.bold()
    // Detail titles, summary headline
    public static let title = Font.title2.bold()
    // Section headers on plain lists
    public static let section = Font.title3.weight(.semibold)
    // Nav title, buttons, emphasised rows
    public static let headline = Font.headline
    // List row titles, text fields
    public static let body = Font.body
    // Row subtitles, descriptions
    public static let subhead = Font.subheadline
    // Field labels, footers, severity text
    public static let footnote = Font.footnote
    // Tab bar labels
    public static let caption = Font.caption2.weight(.medium)
    // Only real codes: hashes, file names, report IDs
    public static let code = Font.footnote.monospaced()
    // Big progress figures ("187 of 243")
    public static let figure = Font.title.weight(.semibold).monospacedDigit()
}
```

`Packages/DesignSystem/Sources/DesignSystem/Tokens/DSSpacing.swift`

```swift
import CoreGraphics

// Spacing scale (points). Use these instead of typing numbers in views.
public enum DSSpacing {
    public static let tiny: CGFloat = 4
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 12
    // Screen side margin, row padding
    public static let regular: CGFloat = 16
    public static let large: CGFloat = 24
    public static let xLarge: CGFloat = 32
}

// Corner radius scale (points).
public enum DSRadius {
    // Small tags
    public static let small: CGFloat = 5
    // Segmented control track
    public static let medium: CGFloat = 9
    // Full-width buttons
    public static let button: CGFloat = 13
    // Sheets, panels
    public static let large: CGFloat = 16
}

// Fixed sizes from the iOS metrics in docs/design/00-design-plan.md.
public enum DSSize {
    public static let buttonHeight: CGFloat = 50
    public static let smallButtonHeight: CGFloat = 34
    public static let rowMinHeight: CGFloat = 52
    // Apple's minimum touch target; gloves need at least this
    public static let minTapTarget: CGFloat = 44
}
```

`Packages/DesignSystem/Tests/DesignSystemTests/DesignSystemTests.swift (replace)`

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

### Check

| Step | Expect |
|---|---|
| Scheme `DesignSystem` → ⌘U | `hexColourIsDecoded` passes |

## P06 · DesignSystem components

- **Goal:** the shared building blocks of the mockups, each with a preview; one gallery screen guarded by a snapshot test.
- Usage: `Button("Save") { … }.buttonStyle(.ds(.primary))`.

`Packages/DesignSystem/Sources/DesignSystem/Components/DSButtonStyle.swift`

```swift
import SwiftUI

// Full-width button in the five looks used by the mockups.
// Usage: Button("Save") { ... }.buttonStyle(.ds(.primary))
public struct DSButtonStyle: ButtonStyle {
    public enum Kind: CaseIterable, Sendable {
        // Graphite fill: the main action of a screen
        case primary
        // Yellow fill: capture only
        case hiVis
        // Light grey fill: second action
        case secondary
        // No fill: third action ("Continue offline")
        case ghost
        // Red text: destructive action
        case danger
    }

    let kind: Kind

    public init(kind: Kind) {
        self.kind = kind
    }

    public func makeBody(configuration: Configuration) -> some View {
        // A separate view, because only a View can read @Environment(\.isEnabled)
        DSButtonBody(kind: kind, label: configuration.label, isPressed: configuration.isPressed)
    }
}

// Lets you write .buttonStyle(.ds(.primary)) instead of .buttonStyle(DSButtonStyle(kind: .primary))
extension ButtonStyle where Self == DSButtonStyle {
    public static func ds(_ kind: DSButtonStyle.Kind) -> DSButtonStyle {
        return DSButtonStyle(kind: kind)
    }
}

private struct DSButtonBody: View {
    let kind: DSButtonStyle.Kind
    let label: ButtonStyleConfiguration.Label
    let isPressed: Bool

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        label
            .font(font)
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: DSSize.buttonHeight)
            .background(background, in: RoundedRectangle(cornerRadius: DSRadius.button))
            .opacity(opacity)
    }

    private var font: Font {
        if kind == .ghost {
            return DSFont.body
        }
        return DSFont.headline
    }

    private var opacity: Double {
        if !isEnabled {
            return 0.4
        }
        if isPressed {
            return 0.7
        }
        return 1
    }

    private var textColor: Color {
        switch kind {
        case .primary:
            return DSColor.onPrimary
        case .hiVis:
            return DSColor.onHiVis
        case .secondary, .ghost:
            return DSColor.textPrimary
        case .danger:
            return DSColor.critical
        }
    }

    private var background: Color {
        switch kind {
        case .primary:
            return DSColor.textPrimary
        case .hiVis:
            return DSColor.hiVis
        case .secondary:
            return DSColor.fill
        case .ghost, .danger:
            return Color.clear
        }
    }
}

#Preview {
    VStack(spacing: DSSpacing.medium) {
        Button("Create project") {}
            .buttonStyle(.ds(.primary))
        Button("Capture") {}
            .buttonStyle(.ds(.hiVis))
        Button("Continue with email") {}
            .buttonStyle(.ds(.secondary))
        Button("Continue offline") {}
            .buttonStyle(.ds(.ghost))
        Button("Delete project") {}
            .buttonStyle(.ds(.danger))
        Button("Disabled") {}
            .buttonStyle(.ds(.primary))
            .disabled(true)
    }
    .padding(DSSpacing.regular)
}
```

`Packages/DesignSystem/Sources/DesignSystem/Components/DSListRow.swift`

```swift
import SwiftUI

// One row of a plain iOS list: title, optional subtitle, optional value, optional chevron.
public struct DSListRow: View {
    let title: String
    let subtitle: String?
    let value: String?
    let showsChevron: Bool

    public init(title: String, subtitle: String? = nil, value: String? = nil, showsChevron: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.showsChevron = showsChevron
    }

    public var body: some View {
        HStack(spacing: DSSpacing.medium) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DSFont.body)
                    .foregroundStyle(DSColor.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(DSFont.subhead)
                        .foregroundStyle(DSColor.textSecondary)
                }
            }

            Spacer(minLength: DSSpacing.small)

            if let value {
                Text(value)
                    .font(DSFont.body)
                    .foregroundStyle(DSColor.textSecondary)
            }

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(DSFont.footnote.weight(.semibold))
                    .foregroundStyle(DSColor.textTertiary)
            }
        }
        .frame(minHeight: DSSize.rowMinHeight)
        .padding(.horizontal, DSSpacing.regular)
        // Makes the empty space tappable too
        .contentShape(Rectangle())
    }
}

#Preview {
    VStack(spacing: 0) {
        DSListRow(title: "Riverside Tower B", subtitle: "District 7 · 14 open issues", showsChevron: true)
        Divider()
            .padding(.leading, DSSpacing.regular)
        DSListRow(title: "Lock after", value: "5 minutes", showsChevron: true)
        Divider()
            .padding(.leading, DSSpacing.regular)
        DSListRow(title: "Living room")
    }
}
```

`Packages/DesignSystem/Sources/DesignSystem/Components/DSSectionHeader.swift`

```swift
import SwiftUI

// Sentence-case section header with an optional grey count on the right ("Level 7      3 open").
public struct DSSectionHeader: View {
    let title: String
    let trailing: String?

    public init(title: String, trailing: String? = nil) {
        self.title = title
        self.trailing = trailing
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(DSFont.section)
                .foregroundStyle(DSColor.textPrimary)

            Spacer()

            if let trailing {
                Text(trailing)
                    .font(DSFont.subhead)
                    .foregroundStyle(DSColor.textSecondary)
            }
        }
        .padding(.horizontal, DSSpacing.regular)
    }
}

#Preview {
    DSSectionHeader(title: "Level 7", trailing: "3 open")
}
```

`Packages/DesignSystem/Sources/DesignSystem/Components/DSChip.swift`

```swift
import SwiftUI

// Filter chip ("All", "Not checked", "Has issues"). Selected = graphite fill.
public struct DSChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSFont.subhead)
                .foregroundStyle(textColor)
                .padding(.horizontal, 13)
                .frame(height: 32)
                .background(backgroundColor, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var textColor: Color {
        if isSelected {
            return DSColor.onPrimary
        }
        return DSColor.textPrimary
    }

    private var backgroundColor: Color {
        if isSelected {
            return DSColor.textPrimary
        }
        return DSColor.fill
    }
}

#Preview {
    HStack(spacing: DSSpacing.small) {
        DSChip(title: "All", isSelected: true, action: {})
        DSChip(title: "Not checked", isSelected: false, action: {})
        DSChip(title: "Has issues", isSelected: false, action: {})
    }
}
```

`Packages/DesignSystem/Sources/DesignSystem/Components/DSStatusMarker.swift`

```swift
import SwiftUI

// Severity and status marker: a small shape + ink text.
// Shapes keep it readable in grayscale and for colour-blind users.
public struct DSStatusMarker: View {
    public enum Kind: CaseIterable, Sendable {
        // ■ red square
        case critical
        // ▲ amber triangle
        case major
        // ○ blue ring
        case minor
        // ● green dot
        case resolved
        // ◌ dashed grey ring (never red)
        case waiting
    }

    let kind: Kind
    let text: String

    public init(kind: Kind, text: String) {
        self.kind = kind
        self.text = text
    }

    public var body: some View {
        HStack(spacing: 6) {
            shape
                .frame(width: 9, height: 9)

            Text(text)
                .font(DSFont.footnote)
                .foregroundStyle(textColor)
        }
    }

    @ViewBuilder private var shape: some View {
        switch kind {
        case .critical:
            RoundedRectangle(cornerRadius: 1)
                .fill(DSColor.critical)
        case .major:
            Triangle()
                .fill(DSColor.major)
        case .minor:
            Circle()
                .strokeBorder(DSColor.minor, lineWidth: 2)
        case .resolved:
            Circle()
                .fill(DSColor.success)
        case .waiting:
            Circle()
                .strokeBorder(DSColor.waiting, style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
        }
    }

    private var textColor: Color {
        switch kind {
        case .resolved, .waiting:
            return DSColor.textSecondary
        case .critical, .major, .minor:
            return DSColor.textPrimary
        }
    }
}

// Triangle pointing up, for the Major marker
private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(alignment: .leading, spacing: DSSpacing.small) {
        DSStatusMarker(kind: .critical, text: "Critical")
        DSStatusMarker(kind: .major, text: "Major")
        DSStatusMarker(kind: .minor, text: "Minor")
        DSStatusMarker(kind: .resolved, text: "Resolved")
        DSStatusMarker(kind: .waiting, text: "Waiting")
    }
}
```

`Packages/DesignSystem/Sources/DesignSystem/Components/DSCountBadge.swift`

```swift
import SwiftUI

// Red count badge, e.g. on the Issues tab or a toolbar button.
public struct DSCountBadge: View {
    let count: Int

    public init(count: Int) {
        self.count = count
    }

    public var body: some View {
        Text(String(count))
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 5)
            .frame(minWidth: 18, minHeight: 18)
            .background(DSColor.critical, in: Capsule())
    }
}

#Preview {
    HStack {
        DSCountBadge(count: 2)
        DSCountBadge(count: 14)
    }
}
```

`Packages/DesignSystem/Sources/DesignSystem/Components/DSEmptyState.swift`

```swift
import SwiftUI

// Shown when a list has nothing yet ("No projects yet").
public struct DSEmptyState: View {
    let systemImage: String
    let title: String
    let message: String

    public init(systemImage: String, title: String, message: String) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: DSSpacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(DSColor.textTertiary)

            Text(title)
                .font(DSFont.headline)
                .foregroundStyle(DSColor.textPrimary)

            Text(message)
                .font(DSFont.subhead)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DSSpacing.large)
    }
}

#Preview {
    DSEmptyState(
        systemImage: "folder",
        title: "No projects yet",
        message: "Create a project to start your first walkthrough."
    )
}
```

`Packages/DesignSystem/Sources/DesignSystem/Components/DSGallery.swift`

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

`SiteLogTests/Snapshots/DesignSystemSnapshotTests.swift`

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

### Check

| Step | Expect |
|---|---|
| Open `DSGallery.swift` → Canvas (⌥⌘↩) | Light and Dark previews |
| ⌘U the first time | Snapshot test fails and records `__Snapshots__/…light.png`, `…dark.png` |
| ⌘U again | Passes; commit the two PNGs |

## P07 · Access flow on fakes

- **Goal:** A2 sign in, A1 Face ID lock, A3 passcode, privacy overlay and re-lock after *Lock after*, all on an in-memory fake.
- **Spec:** [04 §07.2](../feature-docs/04-reporting-security.md#072-app-lock); mockups: Access board.
- Real Keychain + Face ID replace the fake in M3 (P36); real sign-in in M5.

### Flow

| When | Screen |
|---|---|
| Startup ready, first launch | A2 Sign in → **Continue offline** |
| Lock off | Main tabs |
| Lock on + Face ID | A1 → match → main tabs · **Enter passcode** → A3 |
| Lock on, no Face ID | A3 → correct passcode → main tabs |
| App inactive / background, lock on | Privacy overlay on top |
| Back after ≥ *Lock after* | A1 or A3 again (measured with `AppClock.uptime`) |

### 1. Domain contract

`SiteLog/Domain/Access/AccessSettings.swift`

```swift
// Everything the access flow needs to decide which screen comes first.
nonisolated struct AccessSettings: Sendable {
    // false until the user leaves the welcome screen (A2) once
    var hasSeenWelcome: Bool
    // Settings → Privacy → App lock → Lock app
    var isLockEnabled: Bool
    // Settings → Privacy → App lock → Unlock with Face ID
    var isFaceIDEnabled: Bool
    // Settings → Privacy → App lock → Lock after
    var lockAfter: Duration
}
```

`SiteLog/Domain/Access/PasscodeCheck.swift`

```swift
// The answer after the user types 6 digits on A3.
nonisolated enum PasscodeCheck: Sendable {
    // right passcode → open the app
    case correct
    // wrong passcode, still allowed to try
    case wrong(triesLeft: Int)
    // too many wrong tries, must wait this long
    case lockedOut(wait: Duration)
}
```

`SiteLog/Domain/Access/AccessRepository.swift`

```swift
// Domain only says WHAT it needs. HOW (Keychain, Face ID) lives elsewhere.
nonisolated protocol AccessRepository: Sendable {
    func loadSettings() async -> AccessSettings
    func markWelcomeSeen() async
    func checkPasscode(_ passcode: String) async -> PasscodeCheck
    // true when Face ID matched
    func unlockWithBiometrics() async -> Bool
}
```

`SiteLog/Domain/Access/AccessUseCases.swift`

```swift
// One use case per user action. Each one just forwards to the repository for now.

nonisolated struct LoadAccessSettingsUseCase: Sendable {
    private let repository: any AccessRepository

    init(repository: any AccessRepository) {
        self.repository = repository
    }

    func execute() async -> AccessSettings {
        return await repository.loadSettings()
    }
}

nonisolated struct FinishWelcomeUseCase: Sendable {
    private let repository: any AccessRepository

    init(repository: any AccessRepository) {
        self.repository = repository
    }

    func execute() async {
        await repository.markWelcomeSeen()
    }
}

nonisolated struct CheckPasscodeUseCase: Sendable {
    private let repository: any AccessRepository

    init(repository: any AccessRepository) {
        self.repository = repository
    }

    func execute(passcode: String) async -> PasscodeCheck {
        return await repository.checkPasscode(passcode)
    }
}

nonisolated struct UnlockWithBiometricsUseCase: Sendable {
    private let repository: any AccessRepository

    init(repository: any AccessRepository) {
        self.repository = repository
    }

    func execute() async -> Bool {
        return await repository.unlockWithBiometrics()
    }
}
```

### 2. Logger, fake, registrations

`SiteLog/Core/Helper/Logger/AppLogger.swift (replace)`

```swift
import os

// nonisolated: loggers are usable from any actor, not only the main one
nonisolated enum AppLogger {
    static let subsystem = "app.dd.site.log"
    static let startup = Logger(subsystem: subsystem, category: "Startup")
    // new: one category per feature
    static let access = Logger(subsystem: subsystem, category: "Access")
}
```

`SiteLog/Core/Fakes/InMemoryAccessRepository.swift`

```swift
import os

// Fake repository so the whole flow runs today.
// P23 replaces it with a Keychain + Face ID version in Data/.
// Everything resets on every cold launch, because it only lives in memory.
actor InMemoryAccessRepository: AccessRepository {
    // Demo values: lock is on, Face ID is on, re-lock after 10 seconds in the background
    private var settings = AccessSettings(
        hasSeenWelcome: false,
        isLockEnabled: true,
        isFaceIDEnabled: true,
        lockAfter: .seconds(10)
    )

    // Demo passcode for the fake only
    private let demoPasscode = "123456"
    private let freeTries = 5
    private var wrongTries = 0

    func loadSettings() -> AccessSettings {
        return settings
    }

    func markWelcomeSeen() {
        settings.hasSeenWelcome = true
    }

    func checkPasscode(_ passcode: String) -> PasscodeCheck {
        if passcode == demoPasscode {
            wrongTries = 0
            return .correct
        }

        wrongTries += 1
        let triesLeft = freeTries - wrongTries

        if triesLeft > 0 {
            return .wrong(triesLeft: triesLeft)
        }

        return .lockedOut(wait: .seconds(60))
    }

    func unlockWithBiometrics() async -> Bool {
        // Pretend Face ID takes half a second, then always matches
        do {
            try await Task.sleep(for: .milliseconds(500))
        } catch {
            AppLogger.access.error("Fake Face ID sleep cancelled")
            return false
        }

        return true
    }
}
```

`SiteLog/App/AppDependencies.swift (final)`

```swift
import FactoryKit

// Composition root: the only place that knows which implementation backs each protocol.
// Data sources and stateful services are .singleton; use cases are created fresh (unscoped).
extension Container {
    // MARK: - Shared services

    var clock: Factory<any AppClock> {
        self { SystemClock() }.singleton
    }

    // MARK: - Access

    // Fake for now; P36 swaps in the Keychain + Face ID repository from Data/
    var accessRepository: Factory<any AccessRepository> {
        self { InMemoryAccessRepository() }.singleton
    }

    var loadAccessSettings: Factory<LoadAccessSettingsUseCase> {
        self { LoadAccessSettingsUseCase(repository: self.accessRepository()) }
    }

    var finishWelcome: Factory<FinishWelcomeUseCase> {
        self { FinishWelcomeUseCase(repository: self.accessRepository()) }
    }

    var checkPasscode: Factory<CheckPasscodeUseCase> {
        self { CheckPasscodeUseCase(repository: self.accessRepository()) }
    }

    var unlockWithBiometrics: Factory<UnlockWithBiometricsUseCase> {
        self { UnlockWithBiometricsUseCase(repository: self.accessRepository()) }
    }
}
```

### 3. RootViewModel

`SiteLog/Presentation/Root/RootViewModel.swift`

```swift
import FactoryKit
import Observation
import os

@MainActor @Observable
final class RootViewModel {
    // Which screen the access flow shows after startup is ready
    enum Phase {
        case loading
        case welcome
        case faceIDLock
        case passcodeLock
        case unlocked
    }

    private(set) var phase: Phase = .loading
    // true while the app is leaving the screen and the lock is on (hides content in the app switcher)
    private(set) var showsPrivacyOverlay = false

    @ObservationIgnored @Injected(\.loadAccessSettings) private var loadSettings
    @ObservationIgnored private var settings: AccessSettings?
    // uptime keeps counting while the phone sleeps and ignores clock changes (spec 07.2)
    @ObservationIgnored @Injected(\.clock) private var clock
    @ObservationIgnored private var wentToBackgroundAt: ContinuousClock.Instant?

    func load() async {
        let loadedSettings = await loadSettings.execute()
        settings = loadedSettings

        if loadedSettings.hasSeenWelcome {
            lockOrOpen()
        } else {
            phase = .welcome
        }
    }

    func welcomeFinished() {
        lockOrOpen()
    }

    func unlocked() {
        AppLogger.access.info("Unlocked")
        phase = .unlocked
    }

    func usePasscode() {
        phase = .passcodeLock
    }

    // MARK: - App moves between foreground and background

    func appBecameInactive() {
        if isLockEnabled() {
            showsPrivacyOverlay = true
        }
    }

    func appWentToBackground() {
        if isLockEnabled() {
            showsPrivacyOverlay = true
        }

        // Only start the timer when the user was inside the app
        if phase == .unlocked {
            wentToBackgroundAt = clock.uptime
        }
    }

    func appBecameActive() {
        showsPrivacyOverlay = false

        guard let leftAt = wentToBackgroundAt else {
            return
        }
        wentToBackgroundAt = nil

        guard let currentSettings = settings else {
            return
        }

        let timeAway: Duration = clock.uptime - leftAt

        if timeAway >= currentSettings.lockAfter {
            AppLogger.access.info("Lock after reached, locking")
            lockOrOpen()
        }
    }

    // MARK: - Private

    private func isLockEnabled() -> Bool {
        guard let currentSettings = settings else {
            return false
        }
        return currentSettings.isLockEnabled
    }

    // Lock off → main tabs. Lock on → Face ID first if allowed, else passcode.
    private func lockOrOpen() {
        guard let currentSettings = settings else {
            return
        }

        if !currentSettings.isLockEnabled {
            phase = .unlocked
        } else if currentSettings.isFaceIDEnabled {
            phase = .faceIDLock
        } else {
            phase = .passcodeLock
        }
    }
}
```

### 4. A2 Sign in

`SiteLog/Presentation/Access/SignIn/SignInViewModel.swift`

```swift
import FactoryKit
import Observation
import os

@MainActor @Observable
final class SignInViewModel {
    @ObservationIgnored @Injected(\.finishWelcome) private var finishWelcome
    // Called when the user leaves this screen; RootView decides what comes next
    @ObservationIgnored private let onFinished: () -> Void

    init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }

    func signInWithAppleTapped() {
        // Real sign-in comes in P38 (Firebase Auth)
        AppLogger.access.info("Sign in with Apple tapped - not built yet")
    }

    func continueWithEmailTapped() {
        AppLogger.access.info("Continue with email tapped - not built yet")
    }

    func continueOfflineTapped() async {
        AppLogger.access.info("Continue offline tapped")
        await finishWelcome.execute()
        onFinished()
    }
}
```

`SiteLog/Presentation/Access/SignIn/SignInView.swift`

```swift
import DesignSystem
import Inject
import SwiftUI

// A2 - Sign in (optional)
struct SignInView: View {
    @ObserveInjection var inject

    @State private var viewModel: SignInViewModel

    init(onFinished: @escaping () -> Void) {
        // _viewModel is the @State box itself; SwiftUI keeps this view model for the view's lifetime
        _viewModel = State(initialValue: SignInViewModel(onFinished: onFinished))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.large) {
            Spacer()

            Text("Your site log,\non every device.")
                .font(DSFont.largeTitle)
                .foregroundStyle(DSColor.textPrimary)

            Text("Sign in to back up projects and hand off between iPhone and iPad. Everything still works offline without an account.")
                .font(DSFont.body)
                .foregroundStyle(DSColor.textSecondary)

            VStack(alignment: .leading, spacing: DSSpacing.medium) {
                Label("Works with zero signal", systemImage: "antenna.radiowaves.left.and.right.slash")
                Label("Photos hashed at capture", systemImage: "checkmark.seal")
                Label("Signed PDF in one tap", systemImage: "doc.richtext")
            }
            .font(DSFont.body)
            .foregroundStyle(DSColor.textPrimary)

            Spacer()

            VStack(spacing: DSSpacing.small) {
                Button {
                    viewModel.signInWithAppleTapped()
                } label: {
                    Label("Sign in with Apple", systemImage: "apple.logo")
                }
                .buttonStyle(.ds(.primary))

                Button("Continue with email") {
                    viewModel.continueWithEmailTapped()
                }
                .buttonStyle(.ds(.secondary))

                Button("Continue offline") {
                    Task {
                        await viewModel.continueOfflineTapped()
                    }
                }
                .buttonStyle(.ds(.ghost))
            }
        }
        .padding(DSSpacing.large)
        .background(DSColor.canvas)
        .enableInjection()
    }
}

#Preview {
    SignInView(onFinished: {})
}
```

### 5. A1 Face ID lock

`SiteLog/Presentation/Access/FaceIDLock/FaceIDLockViewModel.swift`

```swift
import FactoryKit
import Observation
import os

@MainActor @Observable
final class FaceIDLockViewModel {
    // true while Face ID is checking; the button is disabled meanwhile
    private(set) var isChecking = false

    @ObservationIgnored @Injected(\.unlockWithBiometrics) private var unlockWithBiometrics
    @ObservationIgnored private let onUnlocked: () -> Void
    @ObservationIgnored private let onUsePasscode: () -> Void

    init(onUnlocked: @escaping () -> Void, onUsePasscode: @escaping () -> Void) {
        self.onUnlocked = onUnlocked
        self.onUsePasscode = onUsePasscode
    }

    // Ask for Face ID right away when the screen appears
    func onAppear() async {
        await unlockTapped()
    }

    func unlockTapped() async {
        isChecking = true
        let matched = await unlockWithBiometrics.execute()
        isChecking = false

        if matched {
            onUnlocked()
        } else {
            // Stay on this screen; the user can retry or use the passcode
            AppLogger.access.info("Face ID did not match")
        }
    }

    func usePasscodeTapped() {
        onUsePasscode()
    }
}
```

`SiteLog/Presentation/Access/FaceIDLock/FaceIDLockView.swift`

```swift
import DesignSystem
import Inject
import SwiftUI

// A1 - Face ID lock
struct FaceIDLockView: View {
    @ObserveInjection var inject

    @State private var viewModel: FaceIDLockViewModel

    init(onUnlocked: @escaping () -> Void, onUsePasscode: @escaping () -> Void) {
        let model = FaceIDLockViewModel(onUnlocked: onUnlocked, onUsePasscode: onUsePasscode)
        _viewModel = State(initialValue: model)
    }

    var body: some View {
        VStack(spacing: DSSpacing.regular) {
            Spacer()

            // Placeholder until the AppMark image is in Assets
            Image(systemName: "lock.fill")
                .font(.system(size: 56))
                .foregroundStyle(DSColor.textPrimary)

            Text("SiteLog is locked")
                .font(DSFont.title)
                .foregroundStyle(DSColor.textPrimary)

            Text("Unlock to view site photos and reports.")
                .font(DSFont.subhead)
                .foregroundStyle(DSColor.textSecondary)

            Image(systemName: "faceid")
                .font(.system(size: 48))
                .foregroundStyle(DSColor.textSecondary)
                .padding(.top, DSSpacing.xLarge)

            Spacer()

            Button {
                Task {
                    await viewModel.unlockTapped()
                }
            } label: {
                Label("Unlock with Face ID", systemImage: "faceid")
            }
            .buttonStyle(.ds(.primary))
            .disabled(viewModel.isChecking)

            Button("Enter passcode") {
                viewModel.usePasscodeTapped()
            }
            .buttonStyle(.ds(.ghost))
        }
        .padding(DSSpacing.large)
        .background(DSColor.canvas)
        .task {
            await viewModel.onAppear()
        }
        .enableInjection()
    }
}

#Preview {
    FaceIDLockView(onUnlocked: {}, onUsePasscode: {})
}
```

### 6. A3 Passcode

`SiteLog/Presentation/Access/PasscodeUnlock/PasscodeUnlockViewModel.swift`

```swift
import FactoryKit
import Observation
import os

@MainActor @Observable
final class PasscodeUnlockViewModel {
    let passcodeLength = 6

    // Digits typed so far, e.g. "123"
    private(set) var typedDigits = ""
    // Line under the dots: tries left, wait time
    private(set) var message = ""
    // true after too many wrong tries; the keypad is disabled
    private(set) var isLockedOut = false

    @ObservationIgnored @Injected(\.checkPasscode) private var checkPasscode
    @ObservationIgnored private let onUnlocked: () -> Void

    init(onUnlocked: @escaping () -> Void) {
        self.onUnlocked = onUnlocked
    }

    func digitTapped(_ digit: Int) async {
        if isLockedOut {
            return
        }
        if typedDigits.count >= passcodeLength {
            return
        }

        typedDigits += String(digit)

        // Check as soon as the 6th digit is typed, like the iOS lock screen
        if typedDigits.count == passcodeLength {
            await check()
        }
    }

    func deleteTapped() {
        if typedDigits.isEmpty {
            return
        }
        typedDigits.removeLast()
    }

    func forgotPasscodeTapped() {
        // P23: device passcode check, then set a new app passcode (S5)
        AppLogger.access.info("Forgot passcode tapped - not built yet")
    }

    private func check() async {
        let result = await checkPasscode.execute(passcode: typedDigits)

        // Never log the digits themselves
        switch result {
        case .correct:
            message = ""
            onUnlocked()

        case .wrong(let triesLeft):
            AppLogger.access.info("Wrong passcode, \(triesLeft) tries left")
            typedDigits = ""
            message = "Wrong passcode. \(triesLeft) tries left."

        case .lockedOut(let wait):
            AppLogger.access.info("Passcode locked out")
            typedDigits = ""
            isLockedOut = true
            let minutes = Int(wait.components.seconds / 60)
            message = "Too many tries. Try again in \(minutes) min."
        }
    }
}
```

`SiteLog/Presentation/Access/PasscodeUnlock/PasscodeUnlockView.swift`

```swift
import DesignSystem
import Inject
import SwiftUI

// A3 - Enter passcode
struct PasscodeUnlockView: View {
    @ObserveInjection var inject

    @State private var viewModel: PasscodeUnlockViewModel

    // Keypad layout; the last row (empty, 0, delete) is built by hand below
    private let digitRows: [[Int]] = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
    ]

    init(onUnlocked: @escaping () -> Void) {
        _viewModel = State(initialValue: PasscodeUnlockViewModel(onUnlocked: onUnlocked))
    }

    var body: some View {
        VStack(spacing: DSSpacing.large) {
            Spacer()

            Text("Enter passcode")
                .font(DSFont.title)
                .foregroundStyle(DSColor.textPrimary)

            dots

            Text(viewModel.message)
                .font(DSFont.footnote)
                .foregroundStyle(DSColor.textSecondary)

            Spacer()

            keypad

            Button("Forgot passcode?") {
                viewModel.forgotPasscodeTapped()
            }
            .buttonStyle(.ds(.ghost))
        }
        .padding(DSSpacing.large)
        .background(DSColor.canvas)
        .enableInjection()
    }

    // 6 circles, filled for each typed digit
    private var dots: some View {
        HStack(spacing: DSSpacing.regular) {
            ForEach(0..<viewModel.passcodeLength, id: \.self) { index in
                Circle()
                    .strokeBorder(DSColor.textPrimary, lineWidth: 1)
                    .background(Circle().fill(dotColor(at: index)))
                    .frame(width: 14, height: 14)
            }
        }
    }

    // Filled for every digit typed so far, empty for the rest
    private func dotColor(at index: Int) -> Color {
        if index < viewModel.typedDigits.count {
            return DSColor.textPrimary
        }
        return Color.clear
    }

    private var keypad: some View {
        VStack(spacing: DSSpacing.regular) {
            ForEach(digitRows, id: \.self) { row in
                HStack(spacing: DSSpacing.large) {
                    ForEach(row, id: \.self) { digit in
                        digitKey(digit)
                    }
                }
            }

            HStack(spacing: DSSpacing.large) {
                // Empty slot keeps 0 in the middle column
                Color.clear
                    .frame(width: 76, height: 76)

                digitKey(0)

                Button {
                    viewModel.deleteTapped()
                } label: {
                    Image(systemName: "delete.left")
                        .font(DSFont.title)
                        .foregroundStyle(DSColor.textPrimary)
                        .frame(width: 76, height: 76)
                }
            }
        }
        .disabled(viewModel.isLockedOut)
    }

    private func digitKey(_ digit: Int) -> some View {
        Button {
            Task {
                await viewModel.digitTapped(digit)
            }
        } label: {
            Text(String(digit))
                .font(DSFont.figure)
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: 76, height: 76)
                .background(Circle().fill(DSColor.fill))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PasscodeUnlockView(onUnlocked: {})
}
```

### 7. Privacy overlay

`SiteLog/Presentation/Access/PrivacyOverlay/PrivacyOverlayView.swift`

```swift
import DesignSystem
import SwiftUI

// Covers the app while it is in the app switcher, so site photos never show there
struct PrivacyOverlayView: View {
    var body: some View {
        ZStack {
            DSColor.canvas
                .ignoresSafeArea()

            Image(systemName: "lock.fill")
                .font(.system(size: 56))
                .foregroundStyle(DSColor.textSecondary)
        }
    }
}

#Preview {
    PrivacyOverlayView()
}
```

### 8. RootView (replace)

`SiteLog/Presentation/Root/RootView.swift`

```swift
import Inject
import SwiftUI

struct RootView: View {
    @ObserveInjection var inject

    // foreground / inactive / background, given by SwiftUI
    @Environment(\.scenePhase) private var scenePhase

    @State private var startupVM = StartupViewModel(
        sequence: StartupSequence(steps: [])
    )
    @State private var rootVM = RootViewModel()

    var body: some View {
        // ZStack so the privacy overlay sits on top of whatever screen is showing
        ZStack {
            content

            if rootVM.showsPrivacyOverlay {
                PrivacyOverlayView()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                rootVM.appBecameActive()
            case .inactive:
                rootVM.appBecameInactive()
            case .background:
                rootVM.appWentToBackground()
            @unknown default:
                break
            }
        }
        .enableInjection()
    }

    // Step 1: startup must finish first
    @ViewBuilder private var content: some View {
        switch startupVM.state {
        case .running, .failed:
            StartupView(viewModel: startupVM)
        case .ready:
            accessContent
        }
    }

    // Step 2: welcome → lock → main tabs
    @ViewBuilder private var accessContent: some View {
        switch rootVM.phase {
        case .loading:
            ProgressView()
                .task {
                    await rootVM.load()
                }

        case .welcome:
            SignInView(onFinished: {
                rootVM.welcomeFinished()
            })

        case .faceIDLock:
            FaceIDLockView(
                onUnlocked: {
                    rootVM.unlocked()
                },
                onUsePasscode: {
                    rootVM.usePasscode()
                }
            )

        case .passcodeLock:
            PasscodeUnlockView(onUnlocked: {
                rootVM.unlocked()
            })

        case .unlocked:
            MainTabView()
        }
    }
}
```

### 9. Test

`SiteLogTests/Access/PasscodeUnlockViewModelTests.swift`

```swift
import FactoryKit
import FactoryTesting
import Testing
@testable import SiteLog

@MainActor
@Suite(.container)
struct PasscodeUnlockViewModelTests {
    // Types 6 digits, one tap at a time
    private func type(_ passcode: String, into viewModel: PasscodeUnlockViewModel) async {
        for character in passcode {
            if let digit = Int(String(character)) {
                await viewModel.digitTapped(digit)
            }
        }
    }

    @Test func correctPasscodeUnlocks() async {
        // A fresh fake per test, so wrong tries never leak between tests
        Container.shared.accessRepository.register { InMemoryAccessRepository() }
        var didUnlock = false
        let viewModel = PasscodeUnlockViewModel(onUnlocked: { didUnlock = true })

        await type("123456", into: viewModel)

        #expect(didUnlock)
    }

    @Test func wrongPasscodeShowsTriesLeft() async {
        Container.shared.accessRepository.register { InMemoryAccessRepository() }
        var didUnlock = false
        let viewModel = PasscodeUnlockViewModel(onUnlocked: { didUnlock = true })

        await type("000000", into: viewModel)

        #expect(!didUnlock)
        #expect(viewModel.typedDigits.isEmpty)
        #expect(viewModel.message == "Wrong passcode. 4 tries left.")
    }
}
```

| Line | Why |
|---|---|
| `_viewModel = State(initialValue: …)` | Creates the view model once per screen while still passing it the callbacks from `RootView`. |
| `@ObservationIgnored @Injected(\.useCase)` | Factory resolves the use case; tests swap the repository inside `@Suite(.container)`. |
| `onFinished / onUnlocked / onUsePasscode` | Screens never navigate; they tell `RootViewModel`, which picks the next phase. |
| `nonisolated enum AppLogger` | The fake repository is an `actor`; loggers must be usable off the main actor. |

### Check

| Step | Expect |
|---|---|
| ⌘R | Startup → A2 → **Continue offline** → A1 → fake Face ID unlocks after 0.5 s → tabs |
| Set `isFaceIDEnabled: false` in the fake, ⌘R | A3; 5 wrong tries lock the keypad; `123456` unlocks |
| Home (⇧⌘H), wait > 10 s, reopen | Locked again; the app switcher shows the overlay |
| ⌘U | `PasscodeUnlockViewModelTests` pass |

## Milestone done

| Check | How |
|---|---|
| Zero warnings | ⌘B in Xcode; `Tools/CI/build-strict.sh` |
| All tests green | `bundle exec fastlane test` |
| CI green | PR shows guards, lint, build, test passing |
| Demo on a real device | Access flow and DesignSystem gallery run on your iPhone |
| Roadmap | Tick P02–P07 in `ROADMAP.md` in the commit that finishes each part |
