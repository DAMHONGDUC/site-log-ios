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
- **Fakes:** only in `SiteLog/Data/Fakes/`. Domain and Presentation never name a fake; `AppDependencies` picks it.
- **How to use:** try each file from its hints first; open **Code** only to check or when stuck.
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
SiteLog/
├── Domain/Access/                        # 1: AccessSettings, PasscodeCheck, AccessRepository, AccessUseCases
├── Data/
│   ├── Fakes/InMemoryAccessRepository.swift   # 2
│   └── Security/                         # 4: KeychainAccessRepository, BiometricAuthenticator
├── App/
│   ├── AppDependencies.swift             # 2: access registrations (+ dev data actions)
│   └── DevData/FakeDevDataActions.swift  # 2: dev menu → fakes (Debug only)
├── Core/Helper/Logger/AppLogger.swift    # 2: access category
└── Presentation/
    ├── Root/RootView.swift, RootViewModel.swift      # 3
    ├── Access/SignIn/, FaceIDLock/, PasscodeUnlock/   # 3: + ViewModel next to each view
    └── Settings/AppLock/, SetPasscode/                # 3: + ViewModel next to each view
```

</dd></dl>

## 1. Domain — access types and use cases

<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Domain/Access/AccessSettings.swift`

<b>Explain</b> · The settings that decide which access screen comes first: welcome seen, lock on, Face ID, *Lock after*.

<b>Hint</b>

- `nonisolated struct … : Sendable` with four `var`s.
- `lockAfter` is a `Duration`, not seconds as `Int`.

<details>
<summary><b>Code</b></summary>

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

</details>

---

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Domain/Access/PasscodeCheck.swift`

<b>Explain</b> · Result of checking a typed passcode: correct, wrong with tries left, or locked out.

<b>Hint</b>

- `nonisolated enum` with three cases; `wrong` carries `triesLeft`, `lockedOut` carries `wait`.

<details>
<summary><b>Code</b></summary>

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

</details>

---

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Domain/Access/AccessRepository.swift`

<b>Explain</b> · What the access flow needs from storage; the fake implements it now, Keychain in step 4.

<b>Hint</b>

- `nonisolated protocol … : Sendable`; every method is `async`.
- Load / save settings, mark welcome seen, check / set passcode, unlock with biometrics.

<details>
<summary><b>Code</b></summary>

```swift
// Domain only says WHAT it needs. HOW (memory, Keychain, Face ID) lives in Data/.
nonisolated protocol AccessRepository: Sendable {
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

---

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Domain/Access/AccessUseCases.swift`

<b>Explain</b> · One use case per user action; view models call these, never the repository.

<b>Hint</b>

- One `nonisolated struct` per action, holding `any AccessRepository`.
- Each has one `execute(…)` that forwards to the repository.

<details>
<summary><b>Code</b></summary>

```swift
// One use case per user action. Each one forwards to the repository for now.

nonisolated struct LoadAccessSettingsUseCase: Sendable {
    private let repository: any AccessRepository

    init(repository: any AccessRepository) {
        self.repository = repository
    }

    func execute() async -> AccessSettings {
        return await repository.loadSettings()
    }
}

nonisolated struct SaveAccessSettingsUseCase: Sendable {
    private let repository: any AccessRepository

    init(repository: any AccessRepository) {
        self.repository = repository
    }

    func execute(_ settings: AccessSettings) async {
        await repository.saveSettings(settings)
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

nonisolated struct SetPasscodeUseCase: Sendable {
    private let repository: any AccessRepository

    init(repository: any AccessRepository) {
        self.repository = repository
    }

    func execute(passcode: String) async {
        await repository.setPasscode(passcode)
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

</details>

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

<b>File</b> · <b class="tag-replace">Replace</b> · `SiteLog/Core/Helper/Logger/AppLogger.swift`

<b>Explain</b> · Logger categories, now `nonisolated` and with an `access` category.

<b>Hint</b>

- Make the enum `nonisolated` so actors can log.
- Add an `access` category next to `startup` and `devMenu`.

<details>
<summary><b>Code</b></summary>

```swift
import os

// nonisolated: loggers are usable from any actor, not only the main one
nonisolated enum AppLogger {
    static let subsystem = "app.dd.site.log"
    static let startup = Logger(subsystem: subsystem, category: "Startup")
    // Debug-only developer menu actions
    static let devMenu = Logger(subsystem: subsystem, category: "DevMenu")
    // new: one category per feature
    static let access = Logger(subsystem: subsystem, category: "Access")
}
```

</details>

---

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Data/Fakes/InMemoryAccessRepository.swift`

<b>Explain</b> · Fake `AccessRepository` kept in memory: demo passcode `123456`, Face ID always matches.

<b>Hint</b>

- An `actor` conforming to `AccessRepository`; state lives in private `var`s.
- Passcode check: 5 free tries, then `.lockedOut(wait: .seconds(60))`.
- Fake Face ID: sleep 0.5 s, return `true`.
- `reset()` back to first launch; `seed()` marks the welcome as seen.

<details>
<summary><b>Code</b></summary>

```swift
import os

// Fake repository so the whole flow runs before Keychain and Face ID exist.
// Step 4 replaces it with KeychainAccessRepository; only AppDependencies changes.
// Everything resets on every cold launch, because it only lives in memory.
actor InMemoryAccessRepository: AccessRepository {
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

    func loadSettings() -> AccessSettings {
        return settings
    }

    func saveSettings(_ newSettings: AccessSettings) {
        settings = newSettings
    }

    func markWelcomeSeen() {
        settings.hasSeenWelcome = true
    }

    func checkPasscode(_ typed: String) -> PasscodeCheck {
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

    func setPasscode(_ newPasscode: String) {
        passcode = newPasscode
        wrongTries = 0
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

    // MARK: - Dev menu

    // Delete all data → back to first launch
    func reset() {
        settings = InMemoryAccessRepository.firstLaunch
        passcode = "123456"
        wrongTries = 0
    }

    // Seed data → a returning user: welcome seen, lock on
    func seed() {
        settings.hasSeenWelcome = true
    }
}
```

</details>

---

<b>File</b> · <b class="tag-replace">Replace</b> · `SiteLog/App/AppDependencies.swift` *(F01 version)*

<b>Explain</b> · Registers the access fake, one factory per use case, and the dev menu actions.

<b>Hint</b>

- Register the fake by its concrete type (`inMemoryAccessRepository`, `.singleton`).
- `accessRepository` returns it as `any AccessRepository`; one `Factory` per use case.
- Under `#if DEBUG`, `devDataActions` returns `FakeDevDataActions()`.

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

---

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/App/DevData/FakeDevDataActions.swift`

<b>Explain</b> · Connects the dev menu’s Seed data / Delete all data to the fakes (Debug only).

<b>Hint</b>

- `#if DEBUG` struct conforming to `DevDataActions`.
- Seed / delete call `seed()` / `reset()` on `Container.shared.inMemoryAccessRepository()`.

<details>
<summary><b>Code</b></summary>

```swift
#if DEBUG

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

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/DevMenu/DevMenuSection.swift`

<b>Explain</b> · Takes the dev menu actions from the container; add `import FactoryKit` at the top.

<b>Hint</b>

- The default of `actions` comes from the container instead of `NoopDevDataActions()`.

<details>
<summary><b>Code</b></summary>

```swift
    // was: NoopDevDataActions()
    var actions: any DevDataActions = Container.shared.devDataActions()
```

</details>

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

<b>Hint</b>

- `@MainActor @Observable`; a `Phase` enum: loading, welcome, faceIDLock, passcodeLock, unlocked.
- `load()` reads the settings → welcome, or lock / open.
- Background: remember `clock.uptime`; foreground: re-read settings, lock again if away ≥ *Lock after*.
- `showsPrivacyOverlay` while inactive or in the background with the lock on.

<details>
<summary><b>Code</b></summary>

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

</dd></dl>
</details>

<details open>
<summary><strong>3.2 A2 Sign in</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Presentation/Access/SignIn/SignInViewModel.swift`

<b>Explain</b> · A2 actions: sign-in stubs until F12, and Continue offline.

<b>Hint</b>

- Inject `finishWelcome`; keep an `onFinished` closure from `RootView`.
- Apple / email only log for now; Continue offline runs the use case, then `onFinished()`.

<details>
<summary><b>Code</b></summary>

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

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/SignIn/SignInView.swift`

<b>Explain</b> · Owns a `SignInViewModel` instead of two closures.

<b>Hint</b>

- Swap the two closure properties for `@State private var viewModel`.
- Create it in `init(onFinished:)` with `State(initialValue:)`.

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

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/SignIn/SignInView.swift` *(continued)*

<b>Explain</b> · Dock buttons call the view model.

<b>Hint</b>

- Each dock button calls the view model; Continue offline inside a `Task`.

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

- Preview: `SignInView(onFinished: {})`.

</dd></dl>
</details>

<details open>
<summary><strong>3.3 A1 Face ID lock</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Presentation/Access/FaceIDLock/FaceIDLockViewModel.swift`

<b>Explain</b> · A1: asks for Face ID when the screen appears; the user can switch to the passcode.

<b>Hint</b>

- `isChecking` disables the button while Face ID runs.
- `onAppear()` asks right away; a match calls `onUnlocked`, else stay on the screen.

<details>
<summary><b>Code</b></summary>

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

</details>

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/FaceIDLock/FaceIDLockView.swift`

<b>Explain</b> · Owns a `FaceIDLockViewModel` instead of closures.

<b>Hint</b>

- Replace the closures with a view model created in `init(onUnlocked:onUsePasscode:)`.

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

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/FaceIDLock/FaceIDLockView.swift` *(continued)*

<b>Explain</b> · Dock buttons call the view model; Face ID is asked when the screen appears.

<b>Hint</b>

- Unlock button → `unlockTapped()` in a `Task`, disabled while checking.
- Add `.task { await viewModel.onAppear() }`.

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

</dd></dl>
</details>

<details open>
<summary><strong>3.4 A3 Passcode</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Presentation/Access/PasscodeUnlock/PasscodeUnlockViewModel.swift`

<b>Explain</b> · A3: checks the 6 digits, shows tries left, disables the keypad when locked out.

<b>Hint</b>

- `passcodeEntered(_:)` runs `checkPasscode` and switches on the result.
- Fill `message` for wrong / locked out; set `isLockedOut`; never log the digits.

<details>
<summary><b>Code</b></summary>

```swift
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

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/PasscodeUnlock/PasscodeUnlockView.swift`

<b>Explain</b> · Keeps `code` for the keypad; the view model checks it.

<b>Hint</b>

- Keep `@State code` for the keypad; add the view model in `init(onUnlocked:)`.

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

| In `body` | Change to |
|---|---|
| `Text("2 tries left before a 1-minute wait")` | `Text(viewModel.message)` |
| `PasscodeNumberPad(code: $code)` | add `.disabled(viewModel.isLockedOut)` |
| `Button("Forgot passcode?") {}` | `Button("Forgot passcode?") { viewModel.forgotPasscodeTapped() }` |
| `.onChange(of: code)` | the block below |

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/PasscodeUnlock/PasscodeUnlockView.swift` *(continued)*

<b>Explain</b> · Sends the 6 digits to the view model, then clears them.

<b>Hint</b>

- At 6 digits, hand the code to the view model, then clear it.

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

</dd></dl>
</details>

<details open>
<summary><strong>3.5 RootView</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-replace">Replace</b> · `SiteLog/Presentation/Root/RootView.swift`

<b>Explain</b> · Drives the access flow from `RootViewModel`; replaces the temporary `@State` flow.

<b>Hint</b>

- Own `startupVM` and `rootVM`; a `ZStack` puts the privacy overlay on top.
- Forward `scenePhase` changes to the view model.
- Switch on `rootVM.phase`; every screen gets closures that call `rootVM`.
- Debug: pass `ResetAppAction` that calls `rootVM.load()`.

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

- The skeleton's `FakeAccessStep` enum and `accessStep` state are gone.

</dd></dl>
</details>

<details open>
<summary><strong>3.6 S4 App lock</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Presentation/Settings/AppLock/AppLockViewModel.swift`

<b>Explain</b> · S4: loads and saves Lock app, Face ID and *Lock after*.

<b>Hint</b>

- Bindable `var`s for the toggles and `lockAfter`; a list of `LockAfterOption`.
- `load()` copies the settings in; `save()` writes them back.

<details>
<summary><b>Code</b></summary>

```swift
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

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Settings/AppLock/AppLockView.swift`

<b>Explain</b> · Reads and saves the settings through `AppLockViewModel`.

| In `AppLockView` | Change to |
|---|---|
| `@State isLockOn / isFaceIDOn / lockAfter` and `lockAfterOptions` | `@State private var viewModel = AppLockViewModel()` |
| `toggleRow("Lock app", isOn: $isLockOn)` | `toggleRow("Lock app", isOn: $viewModel.isLockOn)` (same for Face ID) |
| `ForEach(lockAfterOptions, id: \.self)` | `ForEach(viewModel.lockAfterOptions)`; radio on `viewModel.lockAfter == option.value`; tap sets `viewModel.lockAfter = option.value` |
| end of `body` | `.task { await viewModel.load() }` and `.onDisappear { Task { await viewModel.save() } }` |

</dd></dl>
</details>

<details open>
<summary><strong>3.7 S5 Set passcode</strong></summary>
<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Presentation/Settings/SetPasscode/SetPasscodeViewModel.swift`

<b>Explain</b> · S5: enter a new passcode twice; saved only when both match.

<b>Hint</b>

- Two stages: enter, confirm; remember the first entry.
- Match → `setPasscode` + `onDone()`; mismatch → message, back to enter.

<details>
<summary><b>Code</b></summary>

```swift
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

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Settings/SetPasscode/SetPasscodeView.swift`

<b>Explain</b> · Hands the typed digits to `SetPasscodeViewModel`.

| In `SetPasscodeView` | Change to |
|---|---|
| top of the struct | `@State private var viewModel: SetPasscodeViewModel` + `init(onDone:)` like A3 |
| `Text("Enter a 6-digit passcode")` | `Text(viewModel.title)`; add `Text(viewModel.message)` under the dots |
| `.onChange(of: code)` | at 6 digits: `Task { await viewModel.passcodeEntered(newValue); code = "" }` |
| `AppLockView` | `SetPasscodeView(onDone: { isSetPasscodeShown = false })` |

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

<b>Hint</b>

- `@MainActor @Suite(.container)`; register a fresh `InMemoryAccessRepository` per test.
- `123456` unlocks; `000000` leaves “Wrong passcode. 4 tries left.”

<details>
<summary><b>Code</b></summary>

```swift
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
