# F01 — Access and app lock

<dl><dd>

- F01 · 15h · step-by-step guide with full code (steps 1–3); step 4 is a skeleton.

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain — access types and use cases](#1-domain--access-types-and-use-cases)
4. [2. Fake data — in-memory access repository](#2-fake-data--in-memory-access-repository)
5. [3. View models — wire the access screens](#3-view-models--wire-the-access-screens)
6. [4. Real data — Keychain and Face ID](#4-real-data--keychain-and-face-id)
7. [Tests (after the feature works)](#tests-after-the-feature-works)
8. [Feature done](#feature-done)

</dd></dl>

## Overview

<dl><dd>

- **Goal:** A2 sign in, A1 Face ID lock, A3 passcode, privacy overlay, re-lock after *Lock after*, S4 app lock and S5 set passcode — first on a fake repository, then on Keychain + Face ID.
- **Demo:** first launch → Continue offline → tabs; lock on → Face ID or passcode; back after *Lock after* → locked again.
- **Spec:** [07.2 App lock](../feature-docs/04-reporting-security.md#072-app-lock); mockups: Access board, S4, S5.
- **Starts from:** F00 step 1 (Factory, `AppClock`) and the skeleton screens in `Presentation/Access/`, `Settings/AppLock/`, `Settings/SetPasscode/`.
- **Fakes:** only in `Packages/DataLayer/Sources/DataLayer/Fakes/`. Domain and Presentation never name a fake; `AppDependencies` picks it.
- **How to use:** per file, answer **Think** first, write the file, open **Hint 1 → 3** one at a time only when stuck, check against **Code**, then do **Try**.
- **File tags:** <b class="tag-new">New</b> create the file · <b class="tag-edit">Edit</b> change only the part shown · <b class="tag-replace">Replace</b> overwrite the whole file.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--access-types-and-use-cases) | Domain | 1h | not start | `AccessSettings`, `PasscodeCheck`, `AccessRepository`, use cases |
| [2](#2-fake-data--in-memory-access-repository) | Fake data | 1h | not start | `InMemoryAccessRepository`, registrations, dev menu seed / delete |
| [3](#3-view-models--wire-the-access-screens) | View models | 5h | not start | `RootViewModel` + one view model per screen, wired into the skeleton |
| [4](#4-real-data--keychain-and-face-id) | Real data | 8h | not start | `KeychainAccessRepository`, `BiometricAuthenticator` |

<details open>
<summary><strong>Flow</strong></summary>
<dl><dd>

| When | Screen |
|---|---|
| Startup ready, first launch | A2 Sign in → **Continue offline** |
| Lock off | Main tabs |
| Lock on + Face ID | A1 → match → main tabs · **Enter passcode** → A3 |
| Lock on, no Face ID | A3 → correct passcode → main tabs |
| App inactive / background, lock on | Privacy overlay on top |
| Back after ≥ *Lock after* | A1 or A3 again (measured with `AppClock.uptime`) |

</dd></dl>
</details>

</dd></dl>

## Target structure

<dl><dd>

```text
Packages/
├── DomainLayer/Sources/DomainLayer/Access/                 # 1: AccessSettings, PasscodeCheck, AccessRepository, AccessUseCases
├── DataLayer/Sources/DataLayer/
│   ├── Fakes/InMemoryAccessRepository.swift      # 2
│   └── Security/                                 # 4: KeychainAccessRepository, BiometricAuthenticator
└── Core/Sources/Core/Logger/AppLogger.swift      # 2: access category
SiteLog/
├── App/
│   ├── AppDependencies.swift             # 2: access registrations (+ dev data actions)
│   └── DevData/FakeDevDataActions.swift  # 2: dev menu → fakes (Debug only)
└── Presentation/
    ├── Root/RootView.swift, RootViewModel.swift      # 3
    ├── Access/SignIn/, FaceIDLock/, PasscodeUnlock/   # 3: + ViewModel next to each view
    └── Settings/AppLock/, SetPasscode/                # 3: + ViewModel next to each view
```

</dd></dl>

## 1. Domain — access types and use cases

<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `Packages/DomainLayer/Sources/DomainLayer/Access/AccessSettings.swift`

<b>Explain</b> · The settings that decide which access screen comes first: welcome seen, lock on, Face ID, *Lock after*.

<b>Think</b>

- A first-time user and a returning user with the lock on see different screens. Which facts does the app need to decide?
- Why a `Duration` for *Lock after*, not an `Int` of seconds?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- A plain value type with four fields: no logic, no storage.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `public struct … : Sendable`, `public var`, and a `public init` (a struct’s memberwise init is never public).
- `Bool`, `Duration` (`.seconds(10)`).

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
public struct AccessSettings: Sendable {
    // welcome seen?
    // lock on?
    // Face ID on?
    // lock after how long?

    // public init(...): the memberwise one is not public
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
// Everything the access flow needs to decide which screen comes first.
public struct AccessSettings: Sendable {
    // false until the user leaves the welcome screen (A2) once
    public var hasSeenWelcome: Bool
    // Settings → Privacy → App lock → Lock app
    public var isLockEnabled: Bool
    // Settings → Privacy → App lock → Unlock with Face ID
    public var isFaceIDEnabled: Bool
    // Settings → Privacy → App lock → Lock after
    public var lockAfter: Duration

    // The memberwise init is internal; DataLayer needs a public one
    public init(hasSeenWelcome: Bool, isLockEnabled: Bool, isFaceIDEnabled: Bool, lockAfter: Duration) {
        self.hasSeenWelcome = hasSeenWelcome
        self.isLockEnabled = isLockEnabled
        self.isFaceIDEnabled = isFaceIDEnabled
        self.lockAfter = lockAfter
    }
}
```

</details>

<b>Try</b>

- Add `import SwiftUI` at the top and run `Tools/CI/check-imports.sh`. Why must Domain stay Foundation-only? Remove it.
- Delete the `public init`, then build the app after step 2: read what `InMemoryAccessRepository` can no longer do. Put it back.

---

<b>File</b> · <b class="tag-new">New</b> · `Packages/DomainLayer/Sources/DomainLayer/Access/PasscodeCheck.swift`

<b>Explain</b> · Result of checking a typed passcode: correct, wrong with tries left, or locked out.

<b>Think</b>

- After 6 digits, which outcomes are possible, and what extra information does the screen need for each?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- An enum whose cases carry exactly the data the screen needs (associated values).

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `public enum` (its cases are public with it), associated values: `case wrong(triesLeft: Int)`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
public enum PasscodeCheck: Sendable {
    case correct
    case wrong(/* ? */)
    case lockedOut(/* ? */)
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
// The answer after the user types 6 digits on A3.
public enum PasscodeCheck: Sendable {
    // right passcode → open the app
    case correct
    // wrong passcode, still allowed to try
    case wrong(triesLeft: Int)
    // too many wrong tries, must wait this long
    case lockedOut(wait: Duration)
}
```

</details>

<b>Try</b>

- Imagine returning `(ok: Bool, triesLeft: Int?, wait: Duration?)` instead. Which impossible combination could that tuple hold that the enum cannot?

---

<b>File</b> · <b class="tag-new">New</b> · `Packages/DomainLayer/Sources/DomainLayer/Access/AccessRepository.swift`

<b>Explain</b> · What the access flow needs from storage; the fake implements it now, Keychain in step 4.

<b>Think</b>

- Domain must not know about Keychain or Face ID. How can a use case still ask “is this passcode right?”
- The fake answers instantly. Why is every method `async` anyway?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- A protocol listing what the access flow needs from storage; the implementations live in `Data/`.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `public protocol … : Sendable`, `async` methods returning `AccessSettings`, `PasscodeCheck`, `Bool`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
public protocol AccessRepository: Sendable {
    // load / save settings
    // mark welcome seen
    // check / set passcode
    // unlock with biometrics → Bool
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
// Domain only says WHAT it needs. HOW (memory, Keychain, Face ID) lives in Data/.
public protocol AccessRepository: Sendable {
    func loadSettings() async -> AccessSettings
    func saveSettings(_ settings: AccessSettings) async
    func markWelcomeSeen() async
    func checkPasscode(_ passcode: String) async -> PasscodeCheck
    func setPasscode(_ passcode: String) async
    // true when Face ID matched
    func unlockWithBiometrics() async -> Bool
}
```

</details>

<b>Try</b>

- Picture step 4: the real `unlockWithBiometrics` waits for the user’s face. What would break if the method were not `async`?

---

<b>File</b> · <b class="tag-new">New</b> · `Packages/DomainLayer/Sources/DomainLayer/Access/AccessUseCases.swift`

<b>Explain</b> · One use case per user action; view models call these, never the repository.

<b>Think</b>

- Each use case only forwards to the repository. Why have them at all? Where would a rule like “log every failed try” go?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- One small struct per user action: holds the repository, has one `execute`.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `public struct`, `private let repository: any AccessRepository`, `public init(repository:)`, `public func execute(…) async`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
public struct LoadAccessSettingsUseCase: Sendable {
    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        // store it
    }

    public func execute() async -> AccessSettings {
        // ask the repository
    }
}

// Same shape: SaveAccessSettings, FinishWelcome, CheckPasscode,
// SetPasscode, UnlockWithBiometrics
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
// One use case per user action. Each one forwards to the repository for now.

public struct LoadAccessSettingsUseCase: Sendable {
    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute() async -> AccessSettings {
        return await repository.loadSettings()
    }
}

public struct SaveAccessSettingsUseCase: Sendable {
    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute(_ settings: AccessSettings) async {
        await repository.saveSettings(settings)
    }
}

public struct FinishWelcomeUseCase: Sendable {
    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute() async {
        await repository.markWelcomeSeen()
    }
}

public struct CheckPasscodeUseCase: Sendable {
    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute(passcode: String) async -> PasscodeCheck {
        return await repository.checkPasscode(passcode)
    }
}

public struct SetPasscodeUseCase: Sendable {
    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute(passcode: String) async {
        await repository.setPasscode(passcode)
    }
}

public struct UnlockWithBiometricsUseCase: Sendable {
    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute() async -> Bool {
        return await repository.unlockWithBiometrics()
    }
}
```

</details>

<b>Try</b>

- Write the first use case, then the other five without looking. Compare the names with **Code**.

<details open>
<summary><strong>1.1 Check</strong></summary>
<dl><dd>

| Step | Expect |
|---|---|
| ⌘B | Builds; nothing uses the new types yet |

</dd></dl>
</details>

</dd></dl>

## 2. Fake data — in-memory access repository

<dl><dd>

<b>File</b> · <b class="tag-replace">Replace</b> · `Packages/Core/Sources/Core/Logger/AppLogger.swift`

<b>Explain</b> · Logger categories in Core, now with an `access` category.

<b>Think</b>

- DataLayer and the app both log. Why does the logger live in Core, not in the app target?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- The same public enum, plus one category per feature.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `Logger(subsystem:category:)` from `os`, `public static let`.

</details>

<details>
<summary><b>Code</b></summary>

```swift
import os

public enum AppLogger {
    public static let subsystem = "app.dd.site.log"
    public static let startup = Logger(subsystem: subsystem, category: "Startup")
    // Debug-only developer menu actions
    public static let devMenu = Logger(subsystem: subsystem, category: "DevMenu")
    // new: one category per feature
    public static let access = Logger(subsystem: subsystem, category: "Access")
}
```

</details>

<b>Try</b>

- Remove `public` from `access` and build: which files fail, and in which modules? Put it back.
- Open Console.app, filter on subsystem `app.dd.site.log`, and watch the `Access` lines while you use A3.

<b>File</b> · <b class="tag-new">New</b> · `Packages/DataLayer/Sources/DataLayer/Fakes/InMemoryAccessRepository.swift`

<b>Explain</b> · Fake `AccessRepository` in DataLayer, kept in memory: demo passcode `123456`, Face ID always matches.

<b>Think</b>

- Two checks can run at the same time. With a `class`, what could go wrong with `wrongTries += 1`? What does `actor` change?
- What should “Delete all data” bring the app back to?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- An actor holding the settings, the passcode and a wrong-try counter; each protocol method reads or writes them; `reset()` and `seed()` serve the dev menu.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `public actor … : AccessRepository`, `public init() {}`, `public func` for every method the app calls; `import Core`, `import DomainLayer`.
- An actor method satisfies an `async` requirement without writing `async`.
- `private static let firstLaunch`, `try await Task.sleep(for:)` in `do/catch`, `AppLogger.access.error`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import Core
import DomainLayer
import os

public actor InMemoryAccessRepository: AccessRepository {
    private static let firstLaunch = AccessSettings(/* first-launch values */)

    private var settings = InMemoryAccessRepository.firstLaunch
    private var passcode = "123456"
    private let freeTries = 5
    private var wrongTries = 0

    public init() {}

    public func loadSettings() -> AccessSettings { }
    public func saveSettings(_ newSettings: AccessSettings) { }
    public func markWelcomeSeen() { }

    public func checkPasscode(_ typed: String) -> PasscodeCheck {
        // right → reset the counter, .correct
        // wrong → count it, .wrong(triesLeft:) or .lockedOut(wait:)
    }

    public func setPasscode(_ newPasscode: String) { }
    public func unlockWithBiometrics() async -> Bool { /* sleep 0.5 s, true */ }

    public func reset() { /* back to first launch */ }
    public func seed() { /* welcome seen */ }
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
import Core
import DomainLayer
import os

// Fake repository so the whole flow runs before Keychain and Face ID exist.
// Step 4 replaces it with KeychainAccessRepository; only AppDependencies changes.
// Everything resets on every cold launch, because it only lives in memory.
public actor InMemoryAccessRepository: AccessRepository {
    // First-launch values: welcome not seen, lock on, Face ID on, re-lock after 10 seconds
    private static let firstLaunch = AccessSettings(
        hasSeenWelcome: false,
        isLockEnabled: true,
        isFaceIDEnabled: true,
        lockAfter: .seconds(10)
    )

    private var settings = InMemoryAccessRepository.firstLaunch
    // Demo passcode for the fake only
    private var passcode = "123456"
    private let freeTries = 5
    private var wrongTries = 0

    // An actor's default init is internal; AppDependencies needs this one
    public init() {}

    public func loadSettings() -> AccessSettings {
        return settings
    }

    public func saveSettings(_ newSettings: AccessSettings) {
        settings = newSettings
    }

    public func markWelcomeSeen() {
        settings.hasSeenWelcome = true
    }

    public func checkPasscode(_ typed: String) -> PasscodeCheck {
        if typed == passcode {
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

    public func setPasscode(_ newPasscode: String) {
        passcode = newPasscode
        wrongTries = 0
    }

    public func unlockWithBiometrics() async -> Bool {
        // Pretend Face ID takes half a second, then always matches
        do {
            try await Task.sleep(for: .milliseconds(500))
        } catch {
            AppLogger.access.error("Fake Face ID sleep cancelled")
            return false
        }

        return true
    }

    // MARK: - Dev menu

    // Delete all data → back to first launch
    public func reset() {
        settings = InMemoryAccessRepository.firstLaunch
        passcode = "123456"
        wrongTries = 0
    }

    // Seed data → a returning user: welcome seen, lock on
    public func seed() {
        settings.hasSeenWelcome = true
    }
}
```

</details>

<b>Try</b>

- Type 5 wrong passcodes, then the right one. Does it unlock? Should it? Note what the real step 4 version must do differently.

---

<b>File</b> · <b class="tag-replace">Replace</b> · `SiteLog/App/AppDependencies.swift` *(F01 version)*

<b>Explain</b> · Registers the access fake, one factory per use case, and the dev menu actions.

<b>Think</b>

- The dev menu needs `reset()`, which is not part of `AccessRepository`. How can it reach the fake while Presentation never knows the fake exists?
- Why is the repository `.singleton` but the use cases are not?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- Register the fake by its concrete type (singleton), hand it out as the protocol, build each use case from the protocol.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `import Core`, `import DataLayer`, `import DomainLayer`: the composition root is the one app file that imports DataLayer.
- `Factory<InMemoryAccessRepository>`, `Factory<any AccessRepository>`, `self { self.inMemoryAccessRepository() }`, `#if DEBUG`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import Core
import DataLayer
import DomainLayer
import FactoryKit

extension Container {
    var clock: Factory<any AppClock> { /* unchanged */ }

    var inMemoryAccessRepository: Factory<InMemoryAccessRepository> {
        // the fake, singleton
    }

    var accessRepository: Factory<any AccessRepository> {
        // the fake, as the protocol
    }

    var loadAccessSettings: Factory<LoadAccessSettingsUseCase> {
        // built from accessRepository
    }
    // … one per use case

    #if DEBUG
    var devDataActions: Factory<any DevDataActions> { /* FakeDevDataActions() */ }
    #endif
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
import Core
import DataLayer
import DomainLayer
import FactoryKit

// Composition root: the only place that knows which implementation backs each protocol.
// Data sources and stateful services are .singleton; use cases are created fresh (unscoped).
extension Container {
    // MARK: - Shared services

    var clock: Factory<any AppClock> {
        self { SystemClock() }.singleton
    }

    // MARK: - Access

    // The fake, kept by its concrete type so the dev menu can reset / seed it
    var inMemoryAccessRepository: Factory<InMemoryAccessRepository> {
        self { InMemoryAccessRepository() }.singleton
    }

    // Step 4 changes only this line to KeychainAccessRepository
    var accessRepository: Factory<any AccessRepository> {
        self { self.inMemoryAccessRepository() }
    }

    var loadAccessSettings: Factory<LoadAccessSettingsUseCase> {
        self { LoadAccessSettingsUseCase(repository: self.accessRepository()) }
    }

    var saveAccessSettings: Factory<SaveAccessSettingsUseCase> {
        self { SaveAccessSettingsUseCase(repository: self.accessRepository()) }
    }

    var finishWelcome: Factory<FinishWelcomeUseCase> {
        self { FinishWelcomeUseCase(repository: self.accessRepository()) }
    }

    var checkPasscode: Factory<CheckPasscodeUseCase> {
        self { CheckPasscodeUseCase(repository: self.accessRepository()) }
    }

    var setPasscode: Factory<SetPasscodeUseCase> {
        self { SetPasscodeUseCase(repository: self.accessRepository()) }
    }

    var unlockWithBiometrics: Factory<UnlockWithBiometricsUseCase> {
        self { UnlockWithBiometricsUseCase(repository: self.accessRepository()) }
    }

    // MARK: - Dev menu (Debug only)

    #if DEBUG
    var devDataActions: Factory<any DevDataActions> {
        self { FakeDevDataActions() }
    }
    #endif
}
```

</details>

<b>Try</b>

- Remove `.singleton` from `inMemoryAccessRepository`, run, type a wrong passcode twice: does *tries left* go down? Explain why not, then put it back.

---

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/App/DevData/FakeDevDataActions.swift`

<b>Explain</b> · Connects the dev menu’s Seed data / Delete all data to the fakes (Debug only).

<b>Think</b>

- Why does this live in `App/`, not in `Presentation/DevMenu/` or `Packages/DataLayer/Sources/DataLayer/Fakes/`?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- A Debug-only struct that implements the dev menu’s protocol by calling the fakes.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `#if DEBUG … #endif`, `DevDataActions` (`seedData()`, `deleteAllData()`), `await Container.shared.inMemoryAccessRepository().reset()`.

</details>

<details>
<summary><b>Code</b></summary>

```swift
#if DEBUG

import DataLayer
import FactoryKit

// Dev menu → fakes in Data/. Every feature adds its fake here when it lands.
// Lives in App/ because only the composition root may know both sides.
struct FakeDevDataActions: DevDataActions {
    func seedData() async {
        await Container.shared.inMemoryAccessRepository().seed()
    }

    func deleteAllData() async {
        await Container.shared.inMemoryAccessRepository().reset()
    }
}

#endif
```

</details>

<b>Try</b>

- Why must `devDataActions` in `AppDependencies` sit inside `#if DEBUG` too? Remove that `#if`, build for Release, read the error.

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/DevMenu/DevMenuSection.swift`

<b>Explain</b> · Takes the dev menu actions from the container; add `import FactoryKit` at the top.

<b>Think</b>

- Until now `actions` defaulted to a no-op. Who decides the real actions after this change?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- The default value now comes from the container.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `import FactoryKit`, `Container.shared.devDataActions()`.

</details>

<details>
<summary><b>Code</b></summary>

```swift
    // was: NoopDevDataActions()
    var actions: any DevDataActions = Container.shared.devDataActions()
```

</details>

<b>Try</b>

- Dev menu → **Delete all data**, then **Reset the app**: which screen appears, and which methods ran on the way?

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/DevMenu/DevDataActions.swift`

<b>Explain</b> · `NoopDevDataActions` is no longer used: delete that struct.

<details open>
<summary><strong>2.1 Check</strong></summary>
<dl><dd>

| Step | Expect |
|---|---|
| ⌘B | Builds; screens still run on their skeleton closures |

</dd></dl>
</details>

</dd></dl>

## 3. View models — wire the access screens

<dl><dd>

- Screens never navigate: they call a closure, `RootViewModel` picks the next phase.
- Keep each skeleton view's layout; only its data and actions move to the view model.

<details open>
<summary><strong>3.1 RootViewModel</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-replace">Replace</b> · `SiteLog/Presentation/Root/RootViewModel.swift` *(the file is empty today)*

<b>Explain</b> · Decides which screen shows after startup (welcome, Face ID, passcode, tabs) and re-locks after *Lock after*.

<b>Think</b>

- Draw the screens as states and the events that move between them: welcome done, unlocked, use passcode, app left, app back.
- Why measure time away with `uptime`, not `Date`?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- A `Phase` enum is the one source of truth for which screen shows; small methods react to events; a private `lockOrOpen()` holds the lock rule.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `@MainActor @Observable`, `private(set) var`, `@ObservationIgnored @Injected(\.loadAccessSettings)`.
- `ContinuousClock.Instant`; `clock.uptime - leftAt` gives a `Duration`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import Core
import DomainLayer
import FactoryKit
import Observation
import os

@MainActor @Observable
final class RootViewModel {
    enum Phase { /* loading, welcome, faceIDLock, passcodeLock, unlocked */ }

    private(set) var phase: Phase = .loading
    private(set) var showsPrivacyOverlay = false

    // injected: loadAccessSettings, clock
    // remembered: settings, wentToBackgroundAt

    func load() async { /* settings → welcome, or lockOrOpen() */ }
    func welcomeFinished() { }
    func unlocked() { }
    func usePasscode() { }

    func appBecameInactive() { }
    func appWentToBackground() { /* overlay; start the timer only if unlocked */ }
    func appBecameActive() async { /* hide overlay; re-read settings; lock if away ≥ lockAfter */ }

    private func lockOrOpen() { /* lock off → unlocked; Face ID on → faceIDLock; else passcodeLock */ }
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
import Core
import DomainLayer
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

    // Also called by the dev menu's Reset the app
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

    func appBecameActive() async {
        showsPrivacyOverlay = false

        guard let leftAt = wentToBackgroundAt else {
            return
        }
        wentToBackgroundAt = nil

        // Re-read: S4 may have changed Lock app / Face ID / Lock after meanwhile
        let currentSettings = await loadSettings.execute()
        settings = currentSettings

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

</details>

<b>Try</b>

- Remove the `if phase == .unlocked` guard in `appWentToBackground()`. Go Home while A3 is showing, wait 10 s, come back: what changes? Put it back.

</dd></dl>
</details>

<details open>
<summary><strong>3.2 A2 Sign in</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Presentation/Access/SignIn/SignInViewModel.swift`

<b>Explain</b> · A2 actions: sign-in stubs until F12, and Continue offline.

<b>Think</b>

- Why does the view model get an `onFinished` closure instead of setting `RootViewModel.phase` itself?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- One use case, one closure; each button is one method.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `@ObservationIgnored @Injected(\.finishWelcome)`, `@ObservationIgnored private let onFinished: () -> Void`, `init(onFinished: @escaping () -> Void)`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import Core
import DomainLayer
import FactoryKit
import Observation
import os

@MainActor @Observable
final class SignInViewModel {
    // injected finishWelcome
    // onFinished closure

    init(onFinished: @escaping () -> Void) { }

    func signInWithAppleTapped() { /* log only, F12 */ }
    func continueWithEmailTapped() { /* log only */ }
    func continueOfflineTapped() async { /* use case, then onFinished() */ }
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
import Core
import DomainLayer
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
        // Real sign-in comes in F12 (Firebase Auth)
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

</details>

<b>Try</b>

- Remove `@escaping` and read the error. Why must a stored closure be escaping?

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/SignIn/SignInView.swift`

<b>Explain</b> · Owns a `SignInViewModel` instead of two closures.

<b>Think</b>

- SwiftUI rebuilds view structs often. With `let viewModel = SignInViewModel(…)`, what would happen to the view model?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- `@State` keeps the view model for the view’s lifetime; set it once in `init` through `_viewModel`.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `@State private var viewModel: SignInViewModel`, `_viewModel = State(initialValue: …)`.

</details>

<details>
<summary><b>Code</b></summary>

```swift
    // was: var onSignIn / var onContinueOffline
    @State private var viewModel: SignInViewModel

    init(onFinished: @escaping () -> Void) {
        // _viewModel is the @State box itself; SwiftUI keeps this view model for the view's lifetime
        _viewModel = State(initialValue: SignInViewModel(onFinished: onFinished))
    }
```

</details>

<b>Try</b>

- Temporarily add `AppLogger.access.debug("SignInViewModel init")` in the view model’s `init`, tap around, count the lines in Console. Try again with `private let` instead of `@State`. Undo both.

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/SignIn/SignInView.swift` *(continued)*

<b>Explain</b> · Dock buttons call the view model.

<b>Think</b>

- A button action is synchronous, but `continueOfflineTapped()` is `async`. How do you call it?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- Each dock button calls one view model method.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `Task { await … }`, `.buttonStyle(.ds(…))`.

</details>

<details>
<summary><b>Code</b></summary>

```swift
        .bottomDock(showsBackground: false) {
            Button {
                viewModel.signInWithAppleTapped()
            } label: {
                Label("Sign in with Apple", systemImage: "apple.logo")
            }
            .buttonStyle(.ds(.primary))

            Button {
                viewModel.continueWithEmailTapped()
            } label: {
                Label("Continue with email", systemImage: "envelope")
            }
            .buttonStyle(.ds(.secondary))

            Button("Continue offline") {
                Task {
                    await viewModel.continueOfflineTapped()
                }
            }
            .buttonStyle(.ds(.ghost))
        }
```

</details>

<b>Try</b>

- Remove the `Task { }` around the call and read the compiler message.

- Preview: `SignInView(onFinished: {})`.

</dd></dl>
</details>

<details open>
<summary><strong>3.3 A1 Face ID lock</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Presentation/Access/FaceIDLock/FaceIDLockViewModel.swift`

<b>Explain</b> · A1: asks for Face ID when the screen appears; the user can switch to the passcode.

<b>Think</b>

- What should the user see while Face ID runs? What stops a double tap from starting two checks?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- An `isChecking` flag around the use case call; match → closure, no match → stay on the screen.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `private(set) var isChecking`, `@Injected(\.unlockWithBiometrics)`, two closures.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import Core
import DomainLayer
import FactoryKit
import Observation
import os

@MainActor @Observable
final class FaceIDLockViewModel {
    private(set) var isChecking = false
    // injected unlockWithBiometrics; onUnlocked, onUsePasscode

    init(onUnlocked: @escaping () -> Void, onUsePasscode: @escaping () -> Void) { }

    func onAppear() async { /* ask right away */ }
    func unlockTapped() async { /* checking on → ask → checking off → unlock or log */ }
    func usePasscodeTapped() { }
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
import Core
import DomainLayer
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

</details>

<b>Try</b>

- Make the fake’s `unlockWithBiometrics` return `false`. Run: what does A1 do, and how does the user get in? Undo it.

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/FaceIDLock/FaceIDLockView.swift`

<b>Explain</b> · Owns a `FaceIDLockViewModel` instead of closures.

<b>Think</b>

- Same pattern as Sign in: what moves from closures into the view model?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- The view owns the view model in `@State`, created in `init` from the two closures.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `@State private var viewModel`, `State(initialValue:)`.

</details>

<details>
<summary><b>Code</b></summary>

```swift
    // was: var onUnlock / var onEnterPasscode
    @State private var viewModel: FaceIDLockViewModel

    init(onUnlocked: @escaping () -> Void, onUsePasscode: @escaping () -> Void) {
        let model = FaceIDLockViewModel(onUnlocked: onUnlocked, onUsePasscode: onUsePasscode)
        _viewModel = State(initialValue: model)
    }
```

</details>

<b>Try</b>

- Write this `init` from memory, without looking at Sign in.

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/FaceIDLock/FaceIDLockView.swift` *(continued)*

<b>Explain</b> · Dock buttons call the view model; Face ID is asked when the screen appears.

<b>Think</b>

- `.onAppear` or `.task`: which one cancels its work when the view goes away?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- Buttons call the view model; Face ID starts when the screen appears.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `.task { await … }`, `.disabled(viewModel.isChecking)`.

</details>

<details>
<summary><b>Code</b></summary>

```swift
        .bottomDock(showsBackground: false) {
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
        .task {
            await viewModel.onAppear()
        }
```

</details>

<b>Try</b>

- Replace `.task` with `.onAppear { Task { … } }`, then tap **Enter passcode** while Face ID is still running: what keeps going? Undo it.

</dd></dl>
</details>

<details open>
<summary><strong>3.4 A3 Passcode</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Presentation/Access/PasscodeUnlock/PasscodeUnlockViewModel.swift`

<b>Explain</b> · A3: checks the 6 digits, shows tries left, disables the keypad when locked out.

<b>Think</b>

- Which outcome of `PasscodeCheck` needs which text on screen? What must never appear in the logs?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- One method runs the check and `switch`es over the result; each case sets `message` / `isLockedOut`, or unlocks.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `switch result { case .wrong(let triesLeft): … }`, `wait.components.seconds`, string interpolation, `AppLogger.access.info`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import Core
import DomainLayer
import FactoryKit
import Observation
import os

@MainActor @Observable
final class PasscodeUnlockViewModel {
    let passcodeLength = 6
    private(set) var message = ""
    private(set) var isLockedOut = false
    // injected checkPasscode; onUnlocked

    init(onUnlocked: @escaping () -> Void) { }

    func passcodeEntered(_ passcode: String) async {
        let result = await checkPasscode.execute(passcode: passcode)
        switch result {
        case .correct: // clear the message, unlock
        case .wrong(let triesLeft): // log the count only, show the message
        case .lockedOut(let wait): // lock the keypad, show minutes
        }
    }

    func forgotPasscodeTapped() { /* step 4 */ }
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
import Core
import DomainLayer
import FactoryKit
import Observation
import os

@MainActor @Observable
final class PasscodeUnlockViewModel {
    let passcodeLength = 6
    // Line under the dots: tries left, wait time
    private(set) var message = ""
    // true after too many wrong tries; the keypad is disabled
    private(set) var isLockedOut = false

    @ObservationIgnored @Injected(\.checkPasscode) private var checkPasscode
    @ObservationIgnored private let onUnlocked: () -> Void

    init(onUnlocked: @escaping () -> Void) {
        self.onUnlocked = onUnlocked
    }

    // The view calls this when the 6th digit is typed, like the iOS lock screen
    func passcodeEntered(_ passcode: String) async {
        let result = await checkPasscode.execute(passcode: passcode)

        // Never log the digits themselves
        switch result {
        case .correct:
            message = ""
            onUnlocked()
        case .wrong(let triesLeft):
            AppLogger.access.info("Wrong passcode, \(triesLeft) tries left")
            message = "Wrong passcode. \(triesLeft) tries left."
        case .lockedOut(let wait):
            AppLogger.access.info("Passcode locked out")
            isLockedOut = true
            let minutes = Int(wait.components.seconds / 60)
            message = "Too many tries. Try again in \(minutes) min."
        }
    }

    func forgotPasscodeTapped() {
        // Step 4: device passcode check, then set a new app passcode (S5)
        AppLogger.access.info("Forgot passcode tapped - not built yet")
    }
}
```

</details>

<b>Try</b>

- Add a case `.notSet` to `PasscodeCheck` and build: where does the compiler make you handle it? Remove it.

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/PasscodeUnlock/PasscodeUnlockView.swift`

<b>Explain</b> · Keeps `code` for the keypad; the view model checks it.

<b>Think</b>

- Why does `code` stay in the view while the check moves to the view model?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- The keypad’s digits are view state; checking them is logic.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `@State private var viewModel`, `@State private var code`, `init(onUnlocked:)`.

</details>

<details>
<summary><b>Code</b></summary>

```swift
    // was: var onComplete: (String) -> Void
    @State private var viewModel: PasscodeUnlockViewModel
    @State private var code = ""

    init(onUnlocked: @escaping () -> Void) {
        _viewModel = State(initialValue: PasscodeUnlockViewModel(onUnlocked: onUnlocked))
    }
```

</details>

<b>Try</b>

- In one sentence: what belongs in a view’s `@State`, and what belongs in its view model?

| In `body` | Change to |
|---|---|
| `Text("2 tries left before a 1-minute wait")` | `Text(viewModel.message)` |
| `PasscodeNumberPad(code: $code)` | add `.disabled(viewModel.isLockedOut)` |
| `Button("Forgot passcode?") {}` | `Button("Forgot passcode?") { viewModel.forgotPasscodeTapped() }` |
| `.onChange(of: code)` | the block below |

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/PasscodeUnlock/PasscodeUnlockView.swift` *(continued)*

<b>Explain</b> · Sends the 6 digits to the view model, then clears them.

<b>Think</b>

- When should the passcode be checked: on each digit or at the sixth? Why clear `code` afterwards?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- Watch `code`; at full length hand it to the view model, then clear it.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `.onChange(of: code) { _, newValue in … }`, `newValue.count == viewModel.passcodeLength`, `Task`.

</details>

<details>
<summary><b>Code</b></summary>

```swift
        .onChange(of: code) { _, newValue in
            if newValue.count == viewModel.passcodeLength {
                Task {
                    await viewModel.passcodeEntered(newValue)
                    code = ""
                }
            }
        }
```

</details>

<b>Try</b>

- Remove `code = ""`, type a wrong passcode: can you type again? Undo it.

</dd></dl>
</details>

<details open>
<summary><strong>3.5 RootView</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-replace">Replace</b> · `SiteLog/Presentation/Root/RootView.swift`

<b>Explain</b> · Drives the access flow from `RootViewModel`; replaces the temporary `@State` flow.

<b>Think</b>

- Which object owns the access flow’s state, and which one only shows it?
- What does SwiftUI tell you when the app goes to the app switcher or the background?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- A `ZStack` of content plus overlay; `onChange(of: scenePhase)` forwards app events; `content` shows startup until ready, then `accessFlow` switches on `rootVM.phase`.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `@Environment(\.scenePhase)`, `.onChange(of:)`, `@ViewBuilder`, `switch` inside a view, `.task { await rootVM.load() }`, `#if DEBUG`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import Inject
import SwiftUI

struct RootView: View {
    @ObserveInjection var inject
    @Environment(\.scenePhase) private var scenePhase
    @State private var startupVM = /* … */
    @State private var rootVM = RootViewModel()

    var body: some View {
        ZStack {
            content
            // privacy overlay when rootVM.showsPrivacyOverlay
        }
        .onChange(of: scenePhase) { _, newPhase in
            // active / inactive / background → rootVM
        }
        .enableInjection()
    }

    @ViewBuilder private var content: some View { /* startup, or accessFlow + load */ }
    @ViewBuilder private var accessFlow: some View { /* switch rootVM.phase */ }
    @ViewBuilder private var mainTabs: some View { /* MainTabView; resetApp in Debug */ }
}
```

</details>

<details>
<summary><b>Code</b></summary>

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
                Task {
                    await rootVM.appBecameActive()
                }
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

    @ViewBuilder private var content: some View {
        switch startupVM.state {
        case .ready:
            accessFlow
                .task {
                    await rootVM.load()
                }
        case .running, .failed:
            StartupView(viewModel: startupVM)
        }
    }

    @ViewBuilder private var accessFlow: some View {
        switch rootVM.phase {
        case .loading:
            ProgressView()
        case .welcome:
            SignInView(onFinished: {
                rootVM.welcomeFinished()
            })
        case .faceIDLock:
            FaceIDLockView(onUnlocked: {
                rootVM.unlocked()
            }, onUsePasscode: {
                rootVM.usePasscode()
            })
        case .passcodeLock:
            PasscodeUnlockView(onUnlocked: {
                rootVM.unlocked()
            })
        case .unlocked:
            mainTabs
        }
    }

    @ViewBuilder private var mainTabs: some View {
        #if DEBUG
        MainTabView()
            // Dev menu → Reset the app: data is already deleted, so load() lands on onboarding
            .environment(\.resetApp, ResetAppAction {
                Task {
                    await rootVM.load()
                }
            })
        #else
        MainTabView()
        #endif
    }
}
```

</details>

<b>Try</b>

- While unlocked, pull down Control Center: which `scenePhase` arrives, and does the overlay show?

- The skeleton's `FakeAccessStep` enum and `accessStep` state are gone.

</dd></dl>
</details>

<details open>
<summary><strong>3.6 S4 App lock</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Presentation/Settings/AppLock/AppLockViewModel.swift`

<b>Explain</b> · S4: loads and saves Lock app, Face ID and *Lock after*.

<b>Think</b>

- Save on every toggle, or once when the screen closes? What does each choice cost?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- Copy the settings into bindable vars on load; write them back on save; a list of options for the radio rows.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `struct LockAfterOption: Identifiable` with `var id: String { title }`, `guard var updated = settings`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import DomainLayer
import FactoryKit
import Observation

@MainActor @Observable
final class AppLockViewModel {
    struct LockAfterOption: Identifiable { /* title, value, id */ }

    var isLockOn = true
    var isFaceIDOn = true
    var lockAfter: Duration = .seconds(300)
    let lockAfterOptions = [ /* Immediately, 1 min, 5 min, 15 min, 1 h */ ]

    // injected load / save; remembered settings

    func load() async { /* copy the settings in */ }
    func save() async { /* copy the vars back, save */ }
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
import DomainLayer
import FactoryKit
import Observation

@MainActor @Observable
final class AppLockViewModel {
    // One "Lock after" choice: the text on the row and its duration
    struct LockAfterOption: Identifiable {
        let title: String
        let value: Duration

        var id: String {
            title
        }
    }

    var isLockOn = true
    var isFaceIDOn = true
    var lockAfter: Duration = .seconds(300)

    let lockAfterOptions = [
        LockAfterOption(title: "Immediately", value: .zero),
        LockAfterOption(title: "1 minute", value: .seconds(60)),
        LockAfterOption(title: "5 minutes", value: .seconds(300)),
        LockAfterOption(title: "15 minutes", value: .seconds(900)),
        LockAfterOption(title: "1 hour", value: .seconds(3600)),
    ]

    @ObservationIgnored @Injected(\.loadAccessSettings) private var loadSettings
    @ObservationIgnored @Injected(\.saveAccessSettings) private var saveSettings
    @ObservationIgnored private var settings: AccessSettings?

    func load() async {
        let loaded = await loadSettings.execute()
        settings = loaded
        isLockOn = loaded.isLockEnabled
        isFaceIDOn = loaded.isFaceIDEnabled
        lockAfter = loaded.lockAfter
    }

    // Saved when the screen closes
    func save() async {
        guard var updated = settings else {
            return
        }

        updated.isLockEnabled = isLockOn
        updated.isFaceIDEnabled = isFaceIDOn
        updated.lockAfter = lockAfter
        await saveSettings.execute(updated)
        settings = updated
    }
}
```

</details>

<b>Try</b>

- Set *Lock after* to **Immediately**, go Home and straight back: locked? Which methods made that happen?

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Settings/AppLock/AppLockView.swift`

<b>Explain</b> · Reads and saves the settings through `AppLockViewModel`.

<b>Think</b>

- `ForEach(lockAfterOptions, id: \.self)` loses its `id:` argument. Why does `Identifiable` make it unnecessary?

| In `AppLockView` | Change to |
|---|---|
| `@State isLockOn / isFaceIDOn / lockAfter` and `lockAfterOptions` | `@State private var viewModel = AppLockViewModel()` |
| `toggleRow("Lock app", isOn: $isLockOn)` | `toggleRow("Lock app", isOn: $viewModel.isLockOn)` (same for Face ID) |
| `ForEach(lockAfterOptions, id: \.self)` | `ForEach(viewModel.lockAfterOptions)`; radio on `viewModel.lockAfter == option.value`; tap sets `viewModel.lockAfter = option.value` |
| end of `body` | `.task { await viewModel.load() }` and `.onDisappear { Task { await viewModel.save() } }` |

<b>Try</b>

- Change *Lock after*, go back, reopen S4: is the new value shown? Which two view model methods made that happen?

</dd></dl>
</details>

<details open>
<summary><strong>3.7 S5 Set passcode</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Presentation/Settings/SetPasscode/SetPasscodeViewModel.swift`

<b>Explain</b> · S5: enter a new passcode twice; saved only when both match.

<b>Think</b>

- Write the steps of “set a new passcode” as states. What happens on a mismatch?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- A two-stage enum; remember the first entry; compare on confirm.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `enum Stage`, a computed `var title: String`, `@Injected(\.setPasscode)`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import DomainLayer
import FactoryKit
import Observation

@MainActor @Observable
final class SetPasscodeViewModel {
    enum Stage { /* enter, confirm */ }
    private(set) var stage: Stage = .enter
    private(set) var message = ""
    // injected setPasscode; firstEntry; onDone

    init(onDone: @escaping () -> Void) { }

    var title: String { /* one text per stage */ }

    func passcodeEntered(_ passcode: String) async {
        // enter → remember it, go to confirm
        // confirm → match: save + onDone; mismatch: message, back to enter
    }
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
import DomainLayer
import FactoryKit
import Observation

@MainActor @Observable
final class SetPasscodeViewModel {
    // Enter once, then again to confirm
    enum Stage {
        case enter
        case confirm
    }

    private(set) var stage: Stage = .enter
    private(set) var message = ""

    @ObservationIgnored @Injected(\.setPasscode) private var setPasscode
    @ObservationIgnored private var firstEntry = ""
    @ObservationIgnored private let onDone: () -> Void

    init(onDone: @escaping () -> Void) {
        self.onDone = onDone
    }

    var title: String {
        switch stage {
        case .enter:
            return "Enter a 6-digit passcode"
        case .confirm:
            return "Enter it again"
        }
    }

    func passcodeEntered(_ passcode: String) async {
        switch stage {
        case .enter:
            firstEntry = passcode
            message = ""
            stage = .confirm
        case .confirm:
            if passcode == firstEntry {
                await setPasscode.execute(passcode: passcode)
                onDone()
            } else {
                firstEntry = ""
                message = "Passcodes didn’t match. Try again."
                stage = .enter
            }
        }
    }
}
```

</details>

<b>Try</b>

- Why is `firstEntry` `@ObservationIgnored`? Think about what SwiftUI would redraw without it.

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Settings/SetPasscode/SetPasscodeView.swift`

<b>Explain</b> · Hands the typed digits to `SetPasscodeViewModel`.

<b>Think</b>

- This screen and A3 both read 6 digits. Which parts of A3’s wiring can you reuse?

| In `SetPasscodeView` | Change to |
|---|---|
| top of the struct | `@State private var viewModel: SetPasscodeViewModel` + `init(onDone:)` like A3 |
| `Text("Enter a 6-digit passcode")` | `Text(viewModel.title)`; add `Text(viewModel.message)` under the dots |
| `.onChange(of: code)` | at 6 digits: `Task { await viewModel.passcodeEntered(newValue); code = "" }` |
| `AppLockView` | `SetPasscodeView(onDone: { isSetPasscodeShown = false })` |

<b>Try</b>

- Wire it up without reading the table, then compare.

</dd></dl>
</details>

<details open>
<summary><strong>3.8 Check</strong></summary>
<dl><dd>

| Step | Expect |
|---|---|
| ⌘R | Startup → A2 → **Continue offline** → A1 → fake Face ID unlocks after 0.5 s → tabs |
| Settings → App lock → Unlock with Face ID off; Home, wait > 10 s, reopen | A3; 5 wrong tries lock the keypad; `123456` unlocks |
| Home (⇧⌘H), wait > 10 s, reopen | Locked again; the app switcher shows the overlay |
| Settings → App lock → Change passcode | Enter twice; the new passcode unlocks A3 |
| Dev menu → **Reset the app** | Back on A2 |

</dd></dl>
</details>

</dd></dl>

## 4. Real data — Keychain and Face ID

<dl><dd>

- **Goal:** `KeychainAccessRepository` replaces `InMemoryAccessRepository`; screens and view models do not change.
- **Spec:** [07.2](../feature-docs/04-reporting-security.md#072-app-lock)

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `Data/Security/KeychainAccessRepository.swift` | Settings in `UserDefaults`; passcode as PBKDF2-SHA256 with a 16-byte salt and the lockout counter in Keychain |
| <b class="tag-new">New</b> | `Data/Security/BiometricAuthenticator.swift` | `LAContext`, biometry-change detection |
| <b class="tag-edit">Edit</b> | `App/AppDependencies.swift` | `accessRepository` returns `KeychainAccessRepository()` |
| <b class="tag-edit">Edit</b> | `App/DevData/FakeDevDataActions.swift` | Delete all data also clears the Keychain items |

#### Steps

<dl><dd>

1. Add `INFOPLIST_KEY_NSFaceIDUsageDescription` in `project.yml`, run `xcodegen`.
2. Lockout counter survives relaunch; biometry change turns Face ID off.
3. Forgot passcode: device passcode check (`LAContext` `.deviceOwnerAuthentication`), then S5.
4. Change one registration in `AppDependencies`.

</dd></dl>

#### Done when

<dl><dd>

- Relaunch keeps the passcode, settings and lockout

</dd></dl>

</dd></dl>

## Tests (after the feature works)

<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `SiteLogTests/Access/PasscodeUnlockViewModelTests.swift`

<b>Explain</b> · Correct passcode unlocks; a wrong one shows the tries left.

<b>Think</b>

- The fake is a singleton. If test A types a wrong passcode, what does test B see unless something resets it?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- Fresh container per test, a fresh fake, the view model, one `passcodeEntered` call; check the closure and the message.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `@MainActor @Suite(.container)`, `Container.shared.inMemoryAccessRepository.register { … }`, a `var didUnlock` set by the closure, `#expect`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import DataLayer
import FactoryKit
import FactoryTesting
import Testing
@testable import SiteLog

@MainActor
@Suite(.container)
struct PasscodeUnlockViewModelTests {
    @Test func correctPasscodeUnlocks() async {
        // 1. register a fresh fake
        // 2. view model whose onUnlocked sets a flag
        // 3. enter "123456", #expect the flag
    }

    @Test func wrongPasscodeShowsTriesLeft() async {
        // enter "000000", #expect no unlock and the message
    }
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
import DataLayer
import FactoryKit
import FactoryTesting
import Testing
@testable import SiteLog

@MainActor
@Suite(.container)
struct PasscodeUnlockViewModelTests {
    @Test func correctPasscodeUnlocks() async {
        // A fresh fake per test, so wrong tries never leak between tests
        Container.shared.inMemoryAccessRepository.register { InMemoryAccessRepository() }
        var didUnlock = false
        let viewModel = PasscodeUnlockViewModel(onUnlocked: { didUnlock = true })

        await viewModel.passcodeEntered("123456")

        #expect(didUnlock)
    }

    @Test func wrongPasscodeShowsTriesLeft() async {
        Container.shared.inMemoryAccessRepository.register { InMemoryAccessRepository() }
        var didUnlock = false
        let viewModel = PasscodeUnlockViewModel(onUnlocked: { didUnlock = true })

        await viewModel.passcodeEntered("000000")

        #expect(!didUnlock)
        #expect(viewModel.message == "Wrong passcode. 4 tries left.")
    }
}
```

</details>

<b>Try</b>

- Write the `RootViewModel` “*Lock after* reached” test listed below, using `FixedClock` from F00.

- `RootViewModel`: lock off → unlocked; Face ID off → passcode; *Lock after* reached → locked (fixed clock)
- `SetPasscodeViewModel`: mismatch returns to *enter*; match calls `setPasscode`
- `KeychainAccessRepository`: hash round-trip, wrong passcode rejected, lockout survives relaunch, biometry change turns Face ID off

</dd></dl>

## Feature done

<dl><dd>

| Check | How |
|---|---|
| Demo | Lock on device: Face ID, passcode, re-lock after *Lock after*, app switcher overlay |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F01 steps ticked |

</dd></dl>
