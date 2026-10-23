# F01 — Access and app lock

<dl><dd>

- F01 · 15h · access feature guide. Compare every code example with the current implementation before applying it; the repository is the source of truth.
- Follow [F00 localization rules](00-foundation.md#user-facing-text-and-localization) for user-facing text.

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Target structure](#target-structure)
3. [1. Domain — access types and use cases](#1-domain--access-types-and-use-cases)
4. [2. Fake data — access repository in memory](#2-fake-data--access-repository-in-memory)
5. [3. View models — wire the access screens](#3-view-models--wire-the-access-screens)
6. [4. Real data — Keychain and Face ID](#4-real-data--keychain-and-face-id)
7. [Tests (after the feature works)](#tests-after-the-feature-works)
8. [Feature done](#feature-done)

</dd></dl>

## Overview

<dl><dd>

- **Goal:** A2 sign in, A1 Face ID lock, A3 passcode, privacy overlay, re-lock after *Lock after*, S4 app lock and S5 set passcode — on the real `AccessRepositoryImpl` from the start: in-memory values first, Keychain + Face ID in step 4.
- **Demo:** first launch → Continue offline → tabs; lock on → Face ID or passcode; back after *Lock after* → locked again.
- **Spec:** [07.2 App lock](../feature-docs/04-reporting-security.md#072-app-lock); mockups: Access board, S4, S5.
- **Starts from:** F00 step 1 (Factory, `AppClock`) and the skeleton screens in `Presentation/Access/`, `Settings/AppLock/`, `Settings/SetPasscode/`.
- **No fake repository:** step 2 writes the real repository with in-memory values; step 4 swaps its insides, never the type. Test doubles live only in test targets.
- **How to use:** per file, answer **Think** first, write the file, open **Hint 1 → 3** one at a time only when stuck, check against **Code**, then do **Try**.
- **File tags:** <b class="tag-new">New</b> create the file · <b class="tag-edit">Edit</b> change only the part shown · <b class="tag-replace">Replace</b> overwrite the whole file.

| Step | Layer | Hours | Status | What |
|---|---|---|---|---|
| [1](#1-domain--access-types-and-use-cases) | Domain | 1h | not start | `AccessSetting`, `PasscodeCheck`, `AccessError`, `AccessRepository`, use cases |
| [2](#2-fake-data--access-repository-in-memory) | Fake data | 1h | not start | `AccessRepositoryImpl` on in-memory values, registrations, dev menu seed / delete |
| [3](#3-view-models--wire-the-access-screens) | View models | 5h | not start | `RootViewModel` + one view model per screen, wired into the skeleton |
| [4](#4-real-data--keychain-and-face-id) | Real data | 8h | not start | Keychain, `UserDefaults`, Face ID inside `AccessRepositoryImpl` |

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
├── DomainLayer/Sources/DomainLayer/
│   ├── Entities/Access/                                                   # 1: AccessSetting, PasscodeCheck, AccessError
│   ├── Repositories/                                                      # 1: AccessRepository
│   └── UseCases/Access/, UseCases/DevData/                                # 1: one file per use case · 2: dev menu use cases
├── DataLayer/Sources/DataLayer/Repositories/                               # 2: AccessRepositoryImpl (in memory · 4: real storage)
├── DataLayer/Sources/DataLayer/DataSources/Local/Keychain/                  # 4: AccessLocalDataSource, AccessLocalDataSourceImpl
├── PlatformKit/Sources/PlatformKit/Biometrics/                              # 4: BiometricAuthenticating, BiometricAuthenticator
├── Core/Sources/Core/Crypto/PasscodeHasher.swift                            # 4: PBKDF2-SHA256
└── Core/Sources/Core/Logger/AppLogger.swift                                 # 2: access category
SiteLog/
├── App/
│   └── DI/RepositoriesDI.swift, UseCasesDI.swift   # 2: access registrations + dev menu use cases (Debug only)
└── Presentation/
    ├── DevMenu/DevMenuViewModel.swift, ResetAppAction.swift   # 2: dev menu on use cases
    ├── Root/RootView.swift, RootViewModel.swift      # 3
    ├── Access/SignIn/, FaceIDLock/, PasscodeUnlock/   # 3: + ViewModel next to each view
    └── Settings/AppLock/, SetPasscode/                # 3: + ViewModel next to each view
```

</dd></dl>

## 1. Domain — access types and use cases

<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `Packages/DomainLayer/Sources/DomainLayer/Entities/Access/AccessSetting.swift`

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
public struct AccessSetting: Sendable {
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
public struct AccessSetting: Sendable {
    // false until the user leaves the welcome screen (A2) once
    public var isShowWelcomeScreen: Bool
    // Settings → Privacy → App lock → Lock app
    public var isLockOn: Bool
    // Settings → Privacy → App lock → Unlock with Face ID
    public var isFaceIdOn: Bool
    // Settings → Privacy → App lock → Lock after
    public var lockAfterTime: Duration

    // The memberwise init is internal; DataLayer needs a public one
    public init(isShowWelcomeScreen: Bool, isLockOn: Bool, isFaceIdOn: Bool, lockAfterTime: Duration) {
        self.isShowWelcomeScreen = isShowWelcomeScreen
        self.isLockOn = isLockOn
        self.isFaceIdOn = isFaceIdOn
        self.lockAfterTime = lockAfterTime
    }
}
```

</details>

<b>Try</b>

- Add `import SwiftUI` at the top and run `Tools/CI/check-imports.sh`. Why must Domain stay Foundation-only? Remove it.
- Delete the `public init`, then build the app after step 2: read what `AccessRepositoryImpl` can no longer do. Put it back.

---

<b>File</b> · <b class="tag-new">New</b> · `Packages/DomainLayer/Sources/DomainLayer/Entities/Access/PasscodeCheck.swift`

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

<b>File</b> · <b class="tag-new">New</b> · `Packages/DomainLayer/Sources/DomainLayer/Entities/Access/AccessError.swift`

<b>Explain</b> · What can go wrong in the access flow, in Domain words: the `.failure` side of every `AccessRepository` result.

<b>Think</b>

- Step 4 reads Keychain and asks Face ID. Which failures must the screen know about, and which are only “no”?

<details>
<summary><b>Code</b></summary>

```swift
// Left side of every access Result; never a Keychain or LocalAuthentication error.
public enum AccessError: Error, Sendable {
    // Keychain / UserDefaults could not be read or written
    case storageUnavailable
    // Face ID not set up or not allowed
    case biometricsUnavailable
}
```

</details>

---

<b>File</b> · <b class="tag-new">New</b> · `Packages/DomainLayer/Sources/DomainLayer/Repositories/AccessRepository.swift`

<b>Explain</b> · What the access flow needs from storage; `AccessRepositoryImpl` implements it, in memory now, Keychain in step 4.

<b>Think</b>

- Domain must not know about Keychain or Face ID. How can a use case still ask “is this passcode right?”
- Step 2 answers from memory, instantly. Why is every method `async` anyway?
- Keychain can fail in step 4. How does the caller learn that without `try`?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- A protocol listing what the access flow needs from storage; the implementations live in `DataLayer`.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `public protocol … : Sendable`, `async` methods returning `Result<…, AccessError>` (Swift’s Either: `.success` = Right, `.failure` = Left).

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
public protocol AccessRepository: Sendable {
    // load / save settings
    // mark welcome seen
    // check / set passcode
    // unlock with biometrics → Bool
    // every method returns Result<…, AccessError>
    // Debug only: reset all data, seed sample data
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
// Domain only says WHAT it needs. HOW (memory, Keychain, Face ID) lives in Data/.
// Never throws: every call returns Result (rule §4.6).
public protocol AccessRepository: Sendable {
    func loadAccessSetting() async -> Result<AccessSetting, AccessError>
    func saveAccessSetting(newSetting: AccessSetting) async -> Result<Void, AccessError>
    func markWelcomeScreen() async -> Result<Void, AccessError>
    func checkPasscode(inputPasscode: String) async -> Result<PasscodeCheck, AccessError>
    func setPasscode(newPasscode: String) async -> Result<Void, AccessError>
    // .success(true) when Face ID matched
    func unlockWithBiometrics() async -> Result<Bool, AccessError>

    // Dev menu only
    #if DEBUG
    func resetAllData() async
    func seedSampleData() async
    #endif
}
```

</details>

<b>Try</b>

- Picture step 4: the real `unlockWithBiometrics` waits for the user’s face. What would break if the method were not `async`?

---

<b>File</b> · <b class="tag-new">New</b> · `Packages/DomainLayer/Sources/DomainLayer/UseCases/Access/` (6 files)

<b>Explain</b> · One use case per user action, one file each; view models call these, never the repository.

| File | Holds |
|---|---|
| `LoadAccessSettingUseCase.swift` | Reads the settings that pick the first screen. |
| `SaveAccessSettingUseCase.swift` | Saves the App lock settings. |
| `MarkWelcomeScreenUseCase.swift` | Marks the welcome screen as seen, so it never shows again. |
| `CheckPasscodeUseCase.swift` | Checks the 6 typed digits: correct, wrong, or locked out. |
| `SetPasscodeUseCase.swift` | Stores a new passcode (Set passcode screen). |
| `UnlockWithBiometricsUseCase.swift` | Asks Face ID; true when it matched. |

<b>Think</b>

- Each use case only forwards to the repository. Why have them at all? Where would a rule like “log every failed try” go?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- One small struct per user action, in its own file: holds the repository, has one `execute`.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `public struct`, `private let accessRepository: any AccessRepository`, `public init(repository accessRepository:)`, `public func execute(…) async -> Result<…, AccessError>`; pass the repository’s `Result` on.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

`LoadAccessSettingUseCase.swift`

```swift
public struct LoadAccessSettingUseCase: Sendable {
    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        // store it
    }

    public func execute() async -> Result<AccessSetting, AccessError> {
        // ask the accessRepository
    }
}
```

The other five files have the same shape.

</details>

<details>
<summary><b>Code</b></summary>

`LoadAccessSettingUseCase.swift`

```swift
public struct LoadAccessSettingUseCase: Sendable {
    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        self.accessRepository = accessRepository
    }

    public func execute() async -> Result<AccessSetting, AccessError> {
        return await accessRepository.loadAccessSetting()
    }
}
```

`SaveAccessSettingUseCase.swift`

```swift
public struct SaveAccessSettingUseCase: Sendable {
    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        self.accessRepository = accessRepository
    }

    public func execute(setting: AccessSetting) async -> Result<Void, AccessError> {
        return await accessRepository.saveAccessSetting(newSetting: setting)
    }
}
```

`MarkWelcomeScreenUseCase.swift`

```swift
public struct MarkWelcomeScreenUseCase: Sendable {
    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        self.accessRepository = accessRepository
    }

    public func execute() async -> Result<Void, AccessError> {
        return await accessRepository.markWelcomeScreen()
    }
}
```

`CheckPasscodeUseCase.swift`

```swift
public struct CheckPasscodeUseCase: Sendable {
    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        self.accessRepository = accessRepository
    }

    public func execute(passcode: String) async -> Result<PasscodeCheck, AccessError> {
        return await accessRepository.checkPasscode(inputPasscode: passcode)
    }
}
```

`SetPasscodeUseCase.swift`

```swift
public struct SetPasscodeUseCase: Sendable {
    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        self.accessRepository = accessRepository
    }

    public func execute(passcode: String) async -> Result<Void, AccessError> {
        return await accessRepository.setPasscode(newPasscode: passcode)
    }
}
```

`UnlockWithBiometricsUseCase.swift`

```swift
public struct UnlockWithBiometricsUseCase: Sendable {
    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        self.accessRepository = accessRepository
    }

    public func execute() async -> Result<Bool, AccessError> {
        return await accessRepository.unlockWithBiometrics()
    }
}
```

</details>

<b>Try</b>

- Write the first file, then the other five without looking. Compare the names with **Code**.

<details open>
<summary><strong>1.1 Check</strong></summary>
<dl><dd>

| Step | Expect |
|---|---|
| ⌘B | Builds; nothing uses the new types yet |

</dd></dl>
</details>

</dd></dl>

## 2. Fake data — access repository in memory

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

<b>File</b> · <b class="tag-new">New</b> · `Packages/DataLayer/Sources/DataLayer/Repositories/AccessRepositoryImpl.swift`

<b>Explain</b> · The real `AccessRepository`, for now on in-memory values: demo passcode `123456`, Face ID always matches. Step 4 moves the values to Keychain + Face ID.

<b>Think</b>

- Two checks can run at the same time. With a `class`, what could go wrong with `wrongTries += 1`? What does `actor` change?
- What should “Delete all data” bring the app back to?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- An actor holding the settings, the passcode and a wrong-try counter; each protocol method reads or writes them; Debug-only `resetAllData()` and `seedSampleData()` serve the dev menu.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `public actor … : AccessRepository`, `public init() {}`, `public func` for every method the app calls; `import Core`, `import DomainLayer`.
- An actor method satisfies an `async` requirement without writing `async`.
- `private static let firstLaunch`, `try await Task.sleep(for:)` in `do/catch`, `AppLogger.access.error`.
- `#if DEBUG extension AccessRepositoryImpl { … }` for `resetAllData()` / `seedSampleData()`.
- Memory never fails, so step 2 always returns `.success(…)`; `.failure` arrives with Keychain in step 4.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import Core
import DomainLayer
import os

public actor AccessRepositoryImpl: AccessRepository {
    private static let firstLaunch = AccessSetting(/* first-launch values */)

    private var settings = AccessRepositoryImpl.firstLaunch
    private var passcode = "123456"
    private let freeTries = 5
    private var wrongTries = 0

    public init() {}

    public func loadAccessSetting() -> Result<AccessSetting, AccessError> { }
    public func saveAccessSetting(newSetting: AccessSetting) -> Result<Void, AccessError> { }
    public func markWelcomeScreen() -> Result<Void, AccessError> { }

    public func checkPasscode(inputPasscode: String) -> Result<PasscodeCheck, AccessError> {
        // right → reset the counter, .success(.correct)
        // wrong → count it, .success(.wrong(triesLeft:)) or .success(.lockedOut(wait:))
    }

    public func setPasscode(newPasscode: String) -> Result<Void, AccessError> { }
    public func unlockWithBiometrics() async -> Result<Bool, AccessError> { /* sleep 0.5 s, .success(true) */ }
}

#if DEBUG
extension AccessRepositoryImpl {
    public func resetAllData() { /* back to first launch */ }
    public func seedSampleData() { /* welcome seen */ }
}
#endif
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
import Core
import DomainLayer
import os

// In-memory values for now; step 4 moves them to Keychain + Face ID, same type and methods.
public actor AccessRepositoryImpl: AccessRepository {
    // First-launch values: welcome not seen, lock on, Face ID on, re-lock after 10 seconds
    private static let firstLaunch = AccessSetting(
        isShowWelcomeScreen: false,
        isLockOn: true,
        isFaceIdOn: true,
        lockAfterTime: .seconds(10)
    )

    private var settings = AccessRepositoryImpl.firstLaunch
    // Demo passcode until step 4
    private var passcode = "123456"
    private let freeTries = 5
    private var wrongTries = 0

    // An actor's default init is internal; App/DI needs this one
    public init() {}

    public func loadAccessSetting() -> Result<AccessSetting, AccessError> {
        return .success(settings)
    }

    public func saveAccessSetting(newSetting: AccessSetting) -> Result<Void, AccessError> {
        settings = newSetting
        return .success(())
    }

    public func markWelcomeScreen() -> Result<Void, AccessError> {
        settings.isShowWelcomeScreen = true
        return .success(())
    }

    public func checkPasscode(inputPasscode: String) -> Result<PasscodeCheck, AccessError> {
        if inputPasscode == passcode {
            wrongTries = 0
            return .success(.correct)
        }

        wrongTries += 1
        let triesLeft = freeTries - wrongTries

        if triesLeft > 0 {
            return .success(.wrong(triesLeft: triesLeft))
        }

        return .success(.lockedOut(wait: .seconds(60)))
    }

    public func setPasscode(newPasscode: String) -> Result<Void, AccessError> {
        passcode = newPasscode
        wrongTries = 0
        return .success(())
    }

    public func unlockWithBiometrics() async -> Result<Bool, AccessError> {
        // Until step 4: Face ID takes half a second, then always matches
        do {
            try await Task.sleep(for: .milliseconds(500))
        } catch {
            AppLogger.access.error("Face ID sleep cancelled")
            return .success(false)
        }

        return .success(true)
    }
}

// Dev menu only
#if DEBUG
extension AccessRepositoryImpl {
    // Delete all data → back to first launch
    public func resetAllData() {
        settings = AccessRepositoryImpl.firstLaunch
        passcode = "123456"
        wrongTries = 0
    }

    // Seed data → a returning user: welcome seen, lock on
    public func seedSampleData() {
        settings.isShowWelcomeScreen = true
    }
}
#endif
```

</details>

<b>Try</b>

- Type 5 wrong passcodes, then the right one. Does it unlock? Should it? Note what step 4 must do differently.
- Kill the app and reopen: the passcode and settings are back to first launch. Which step makes them survive?

---

<b>File</b> · <b class="tag-new">New</b> · `Packages/DomainLayer/Sources/DomainLayer/UseCases/DevData/` (2 files, Debug only)

<b>Explain</b> · The dev menu’s actions as use cases, like any other screen; each calls the repository’s Debug-only method.

| File | Holds |
|---|---|
| `ResetAllAccessDataUseCase.swift` | Back to first launch: calls `resetAllData()` |
| `SeedAccessDataUseCase.swift` | Sample access data: calls `seedSampleData()` |

<details>
<summary><b>Code</b></summary>

`ResetAllAccessDataUseCase.swift`

```swift
#if DEBUG
// Dev menu: back to first launch for the access flow
public struct ResetAllAccessDataUseCase {
    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        self.accessRepository = accessRepository
    }

    public func execute() async {
        await accessRepository.resetAllData()
    }
}
#endif
```

`SeedAccessDataUseCase.swift`

```swift
#if DEBUG
// Dev menu: put sample access settings in place
public struct SeedAccessDataUseCase {
    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        self.accessRepository = accessRepository
    }

    public func execute() async {
        await accessRepository.seedSampleData()
    }
}
#endif
```

</details>

<b>Try</b>

- Remove `#if DEBUG` from one use case and build for Release: what fails, and why is that the right failure?

---

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/App/DI/RepositoriesDI.swift`

<b>Explain</b> · Registers the access repository once, as its protocol. The composition root has one file per layer.

<b>Think</b>

- Why is the repository `.singleton` but the use cases are not?
- Why is `App/DI/` the only app folder that imports `DataLayer`?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- Register the repository once, as the protocol, singleton.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `import DataLayer`, `import DomainLayer`, `import FactoryKit`.
- `Factory<any AccessRepository>`, `self { AccessRepositoryImpl() }.singleton`.

</details>

<details>
<summary><b>Code</b></summary>

```swift
import DataLayer
import DomainLayer
import FactoryKit

extension Container {
    var accessRepository: Factory<any AccessRepository> {
        self { AccessRepositoryImpl() }.singleton
    }
}
```

</details>

---

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/App/DI/UseCasesDI.swift`

<b>Explain</b> · One factory per use case, grouped by feature with `// MARK:`; the two dev menu use cases sit under `#if DEBUG`.

<b>Think</b>

- This file never imports `DataLayer`. How does it still reach `AccessRepositoryImpl`?
- Why must the dev menu factories sit inside `#if DEBUG`?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- Build each use case from `self.accessRepository()`; no scope, so each resolve makes a new one.

</details>

<details open>
<summary><b>Hint 2 · Skeleton</b></summary>

```swift
import DomainLayer
import FactoryKit

extension Container {
    // MARK: - Access

    var loadAccessSettingUseCase: Factory<LoadAccessSettingUseCase> {
        // built from accessRepository
    }
    // … one per use case

    // MARK: - Dev menu (Debug only)

    #if DEBUG
    var resetAllAccessDataUseCase: Factory<ResetAllAccessDataUseCase> { /* from accessRepository */ }
    var seedAccessDataUseCase: Factory<SeedAccessDataUseCase> { /* from accessRepository */ }
    #endif
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
import DomainLayer
import FactoryKit

extension Container {
    // MARK: - Access

    var loadAccessSettingUseCase: Factory<LoadAccessSettingUseCase> {
        self { LoadAccessSettingUseCase(repository: self.accessRepository()) }
    }

    var saveAccessSettingUseCase: Factory<SaveAccessSettingUseCase> {
        self { SaveAccessSettingUseCase(repository: self.accessRepository()) }
    }

    var markWelcomeScreenUseCase: Factory<MarkWelcomeScreenUseCase> {
        self { MarkWelcomeScreenUseCase(repository: self.accessRepository()) }
    }

    var checkPasscodeUseCase: Factory<CheckPasscodeUseCase> {
        self { CheckPasscodeUseCase(repository: self.accessRepository()) }
    }

    var setPasscodeUseCase: Factory<SetPasscodeUseCase> {
        self { SetPasscodeUseCase(repository: self.accessRepository()) }
    }

    var unlockWithBiometricsUseCase: Factory<UnlockWithBiometricsUseCase> {
        self { UnlockWithBiometricsUseCase(repository: self.accessRepository()) }
    }

    // MARK: - Dev menu (Debug only)

    #if DEBUG
    var resetAllAccessDataUseCase: Factory<ResetAllAccessDataUseCase> {
        self { ResetAllAccessDataUseCase(repository: self.accessRepository()) }
    }

    var seedAccessDataUseCase: Factory<SeedAccessDataUseCase> {
        self { SeedAccessDataUseCase(repository: self.accessRepository()) }
    }
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

    var accessRepository: Factory<any AccessRepository> {
        self { AccessRepositoryImpl() }.singleton
    }

    var loadAccessSettingUseCase: Factory<LoadAccessSettingUseCase> {
        self { LoadAccessSettingUseCase(repository: self.accessRepository()) }
    }

    var saveAccessSettingUseCase: Factory<SaveAccessSettingUseCase> {
        self { SaveAccessSettingUseCase(repository: self.accessRepository()) }
    }

    var markWelcomeScreenUseCase: Factory<MarkWelcomeScreenUseCase> {
        self { MarkWelcomeScreenUseCase(repository: self.accessRepository()) }
    }

    var checkPasscodeUseCase: Factory<CheckPasscodeUseCase> {
        self { CheckPasscodeUseCase(repository: self.accessRepository()) }
    }

    var setPasscodeUseCase: Factory<SetPasscodeUseCase> {
        self { SetPasscodeUseCase(repository: self.accessRepository()) }
    }

    var unlockWithBiometricsUseCase: Factory<UnlockWithBiometricsUseCase> {
        self { UnlockWithBiometricsUseCase(repository: self.accessRepository()) }
    }

    // MARK: - Dev menu (Debug only)

    #if DEBUG
    var resetAllAccessDataUseCase: Factory<ResetAllAccessDataUseCase> {
        self { ResetAllAccessDataUseCase(repository: self.accessRepository()) }
    }

    var seedAccessDataUseCase: Factory<SeedAccessDataUseCase> {
        self { SeedAccessDataUseCase(repository: self.accessRepository()) }
    }
    #endif
}
```

</details>

<b>Try</b>

- Remove `.singleton` from `accessRepository`, run, type a wrong passcode twice: does *tries left* go down? Explain why not, then put it back.

---

<b>File</b> · <b class="tag-new">New</b> · `SiteLog/Presentation/DevMenu/DevMenuViewModel.swift`

<b>Explain</b> · The dev menu’s view model: Seed data and Delete all data call the DevData use cases (Debug only).

<b>Think</b>

- F02 adds projects. How does Delete all data wipe them too, without the dev menu view changing?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- Like every view model: use cases through `init`, one method per button; each feature adds its reset and seed use cases here.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `#if DEBUG … #endif`, `@MainActor @Observable`, `init(resetAllAccessDataUseCase:seedAccessDataUseCase:)`.

</details>

<details>
<summary><b>Code</b></summary>

```swift
#if DEBUG

import DomainLayer
import Observation

@MainActor @Observable
final class DevMenuViewModel {
    @ObservationIgnored private let resetAllAccessDataUseCase: ResetAllAccessDataUseCase
    @ObservationIgnored private let seedAccessDataUseCase: SeedAccessDataUseCase

    init(resetAllAccessDataUseCase: ResetAllAccessDataUseCase, seedAccessDataUseCase: SeedAccessDataUseCase) {
        self.resetAllAccessDataUseCase = resetAllAccessDataUseCase
        self.seedAccessDataUseCase = seedAccessDataUseCase
    }

    // Each feature adds its seed use case here
    func seedData() async {
        await seedAccessDataUseCase.execute()
    }

    // Each feature adds its reset use case here
    func deleteAllData() async {
        await resetAllAccessDataUseCase.execute()
    }
}

#endif
```

</details>

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/DevMenu/DevMenuSection.swift`

<b>Explain</b> · Owns a `DevMenuViewModel` built from the container; add `import FactoryKit` at the top.

<b>Think</b>

- Until now `actions` defaulted to a no-op. Who decides the real actions after this change?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- `@State` keeps the view model; the view resolves the two use cases, the view model never sees the container.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `import FactoryKit`, `Container.shared.resetAllAccessDataUseCase()`, `Container.shared.seedAccessDataUseCase()`.

</details>

<details>
<summary><b>Code</b></summary>

```swift
    // was: var actions: any DevDataActions = NoopDevDataActions()
    @State private var viewModel = DevMenuViewModel(
        resetAllAccessDataUseCase: Container.shared.resetAllAccessDataUseCase(),
        seedAccessDataUseCase: Container.shared.seedAccessDataUseCase()
    )

    // and in the buttons: actions.seedData() → viewModel.seedData(), actions.deleteAllData() → viewModel.deleteAllData()
```

</details>

<b>Try</b>

- Dev menu → **Delete all data**, then **Reset the app**: which screen appears, and which methods ran on the way?

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/DevMenu/DevDataActions.swift` → rename to `ResetAppAction.swift`

<b>Explain</b> · `DevDataActions` and `NoopDevDataActions` are no longer used: delete both; the file keeps only `ResetAppAction` and its environment value.

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

- `@MainActor @Observable`, `private(set) var`, `private let loadSettingsUseCase: LoadAccessSettingUseCase` and `private let clock: any AppClock` set in `init`.
- `ContinuousClock.Instant`; `clock.uptime - leftAt` gives a `Duration`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import Core
import DomainLayer
import Observation
import os

@MainActor @Observable
final class RootViewModel {
    enum Phase { /* loading, welcome, faceIDLock, passcodeLock, unlocked */ }

    private(set) var phase: Phase = .loading
    private(set) var showsPrivacyOverlay = false

    // init(loadSettingsUseCase:clock:): passed in, never looked up
    // remembered: settings, wentToBackgroundAt

    func load() async { /* settings → welcome, or lockOrOpen() */ }
    func welcomeFinished() { }
    func unlocked() { }
    func usePasscode() { }

    func appBecameInactive() { }
    func appWentToBackground() { /* overlay; start the timer only if unlocked */ }
    func appBecameActive() async { /* hide overlay; re-read settings; lock if away ≥ lockAfterTime */ }

    private func lockOrOpen() { /* lock off → unlocked; Face ID on → faceIDLock; else passcodeLock */ }
}
```

</details>

<details>
<summary><b>Code</b></summary>

```swift
import Core
import DomainLayer
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

    @ObservationIgnored private let loadSettingsUseCase: LoadAccessSettingUseCase
    // uptime keeps counting while the phone sleeps and ignores clock changes (spec 07.2)
    @ObservationIgnored private let clock: any AppClock
    @ObservationIgnored private var settings: AccessSetting?
    @ObservationIgnored private var wentToBackgroundAt: ContinuousClock.Instant?

    // RootView passes these in from the container; tests pass stubs
    init(loadSettingsUseCase: LoadAccessSettingUseCase, clock: any AppClock) {
        self.loadSettingsUseCase = loadSettingsUseCase
        self.clock = clock
    }

    // Also called by the dev menu's Reset the app
    func load() async {
        switch await loadSettingsUseCase.execute() {
        case .success(let loadedSettings):
            settings = loadedSettings

            if loadedSettings.isShowWelcomeScreen {
                lockOrOpen()
            } else {
                phase = .welcome
            }
        case .failure(let error):
            // Settings unreadable: lock rather than open the app unlocked
            AppLogger.access.error("Load access settings failed: \(String(reflecting: error))")
            phase = .passcodeLock
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
        switch await loadSettingsUseCase.execute() {
        case .success(let reloaded):
            settings = reloaded
        case .failure(let error):
            AppLogger.access.error("Reload access settings failed, keeping the last ones: \(String(reflecting: error))")
        }

        guard let currentSettings = settings else {
            return
        }

        let timeAway: Duration = clock.uptime - leftAt

        if timeAway >= currentSettings.lockAfterTime {
            AppLogger.access.info("Lock after reached, locking")
            lockOrOpen()
        }
    }

    // MARK: - Private

    private func isLockEnabled() -> Bool {
        guard let currentSettings = settings else {
            return false
        }
        return currentSettings.isLockOn
    }

    // Lock off → main tabs. Lock on → Face ID first if allowed, else passcode.
    private func lockOrOpen() {
        guard let currentSettings = settings else {
            return
        }

        if !currentSettings.isLockOn {
            phase = .unlocked
        } else if currentSettings.isFaceIdOn {
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

- `@ObservationIgnored private let markWelcomeScreenUseCase: MarkWelcomeScreenUseCase`, `@ObservationIgnored private let onFinished: () -> Void`, `init(markWelcomeScreenUseCase:onFinished:)`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import Core
import DomainLayer
import Observation
import os

@MainActor @Observable
final class SignInViewModel {
    // markWelcomeScreenUseCase dependency and onFinished closure: both passed in

    init(markWelcomeScreenUseCase: MarkWelcomeScreenUseCase, onFinished: @escaping () -> Void) { }

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
import Observation
import os

@MainActor @Observable
final class SignInViewModel {
    @ObservationIgnored private let markWelcomeScreenUseCase: MarkWelcomeScreenUseCase
    // Called when the user leaves this screen; RootView decides what comes next
    @ObservationIgnored private let onFinished: () -> Void

    init(markWelcomeScreenUseCase: MarkWelcomeScreenUseCase, onFinished: @escaping () -> Void) {
        self.markWelcomeScreenUseCase = markWelcomeScreenUseCase
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

        switch await markWelcomeScreenUseCase.execute() {
        case .success:
            AppLogger.access.info("Welcome marked as seen")
        case .failure(let error):
            // Not fatal: the welcome screen shows once more on the next launch
            AppLogger.access.error("Mark welcome seen failed: \(String(reflecting: error))")
        }

        onFinished()
    }
}
```

</details>

<b>Try</b>

- Remove `@escaping` and read the error. Why must a stored closure be escaping?

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/SignIn/SignInScreen.swift`

<b>Explain</b> · Owns a `SignInViewModel` instead of two closures; add `import FactoryKit` at the top: the view, not the view model, reads the container.

<b>Think</b>

- SwiftUI rebuilds view structs often. With `let viewModel = SignInViewModel(…)`, what would happen to the view model?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- `@State` keeps the view model for the view’s lifetime; set it once in `init` through `_viewModel`.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `@State private var viewModel: SignInViewModel`, `_viewModel = State(initialValue: …)`, `Container.shared.markWelcomeScreenUseCase()`.

</details>

<details>
<summary><b>Code</b></summary>

```swift
    // was: var onSignIn / var onContinueOffline
    @State private var viewModel: SignInViewModel

    init(onFinished: @escaping () -> Void) {
        // The view hands the use case in; the view model never touches the container
        let model = SignInViewModel(
            markWelcomeScreenUseCase: Container.shared.markWelcomeScreenUseCase(),
            onFinished: onFinished
        )
        // _viewModel is the @State box itself; SwiftUI keeps this view model for the view's lifetime
        _viewModel = State(initialValue: model)
    }
```

</details>

<b>Try</b>

- Temporarily add `AppLogger.access.debug("SignInViewModel init")` in the view model’s `init`, tap around, count the lines in Console. Try again with `private let` instead of `@State`. Undo both.

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/SignIn/SignInScreen.swift` *(continued)*

<b>Explain</b> · Dock buttons call the view model.

<b>Think</b>

- A button action is synchronous, but `continueOfflineTapped()` is `async`. How do you call it?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- Each dock button calls one view model method.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `Task { await … }`, `.buttonStyle(.sd(…))`.

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
            .buttonStyle(.sd(.primary))

            Button {
                viewModel.continueWithEmailTapped()
            } label: {
                Label("Continue with email", systemImage: "envelope")
            }
            .buttonStyle(.sd(.secondary))

            Button("Continue offline") {
                Task {
                    await viewModel.continueOfflineTapped()
                }
            }
            .buttonStyle(.sd(.ghost))
        }
```

</details>

<b>Try</b>

- Remove the `Task { }` around the call and read the compiler message.

- Preview: `SignInScreen(onFinished: {})`.

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

- `private(set) var isChecking`, `private let unlockWithBiometricsUseCase: UnlockWithBiometricsUseCase`, two closures; all three through `init`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import Core
import DomainLayer
import Observation
import os

@MainActor @Observable
final class FaceIDLockViewModel {
    private(set) var isChecking = false
    // unlockWithBiometricsUseCase, onUnlocked, onUsePasscode: passed in

    init(
        unlockWithBiometricsUseCase: UnlockWithBiometricsUseCase,
        onUnlocked: @escaping () -> Void,
        onUsePasscode: @escaping () -> Void
    ) { }

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
import Observation
import os

@MainActor @Observable
final class FaceIDLockViewModel {
    // true while Face ID is checking; the button is disabled meanwhile
    private(set) var isChecking = false

    @ObservationIgnored private let unlockWithBiometricsUseCase: UnlockWithBiometricsUseCase
    @ObservationIgnored private let onUnlocked: () -> Void
    @ObservationIgnored private let onUsePasscode: () -> Void

    init(
        unlockWithBiometricsUseCase: UnlockWithBiometricsUseCase,
        onUnlocked: @escaping () -> Void,
        onUsePasscode: @escaping () -> Void
    ) {
        self.unlockWithBiometricsUseCase = unlockWithBiometricsUseCase
        self.onUnlocked = onUnlocked
        self.onUsePasscode = onUsePasscode
    }

    // Ask for Face ID right away when the screen appears
    func onAppear() async {
        await unlockTapped()
    }

    func unlockTapped() async {
        isChecking = true
        let result = await unlockWithBiometricsUseCase.execute()
        isChecking = false

        switch result {
        case .success(true):
            onUnlocked()
        case .success(false):
            // Stay on this screen; the user can retry or use the passcode
            AppLogger.access.info("Face ID did not match")
        case .failure(let error):
            AppLogger.access.error("Face ID failed: \(String(reflecting: error))")
        }
    }

    func usePasscodeTapped() {
        onUsePasscode()
    }
}
```

</details>

<b>Try</b>

- Make step 2’s `unlockWithBiometrics` return `false`. Run: what does A1 do, and how does the user get in? Undo it.

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/FaceIDLock/FaceIDLockScreen.swift`

<b>Explain</b> · Owns a `FaceIDLockViewModel` instead of closures.

<b>Think</b>

- Same pattern as Sign in: what moves from closures into the view model?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- The view owns the view model in `@State`, created in `init` from the container’s use case and the two closures; add `import FactoryKit`.

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
        let model = FaceIDLockViewModel(
            unlockWithBiometricsUseCase: Container.shared.unlockWithBiometricsUseCase(),
            onUnlocked: onUnlocked,
            onUsePasscode: onUsePasscode
        )
        _viewModel = State(initialValue: model)
    }
```

</details>

<b>Try</b>

- Write this `init` from memory, without looking at Sign in.

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/FaceIDLock/FaceIDLockScreen.swift` *(continued)*

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
            .buttonStyle(.sd(.primary))
            .disabled(viewModel.isChecking)

            Button("Enter passcode") {
                viewModel.usePasscodeTapped()
            }
            .buttonStyle(.sd(.ghost))
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

- `switch result { case .success(.wrong(let triesLeft)): … }`, `wait.components.seconds`, string interpolation, `AppLogger.access.info`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import Core
import DomainLayer
import Observation
import os

@MainActor @Observable
final class PasscodeUnlockViewModel {
    let passcodeLength = 6
    private(set) var message = ""
    private(set) var isLockedOut = false
    // checkPasscodeUseCase use case, onUnlocked closure: passed in

    init(checkPasscodeUseCase: CheckPasscodeUseCase, onUnlocked: @escaping () -> Void) { }

    func passcodeEntered(_ passcode: String) async {
        switch await checkPasscodeUseCase.execute(passcode: passcode) {
        case .success(.correct): // clear the message, unlock
        case .success(.wrong(let triesLeft)): // log the count only, show the message
        case .success(.lockedOut(let wait)): // lock the keypad, show minutes
        case .failure(let error): // log, ask to try again
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
import Observation
import os

@MainActor @Observable
final class PasscodeUnlockViewModel {
    let passcodeLength = 6
    // Line under the dots: tries left, wait time
    private(set) var message = ""
    // true after too many wrong tries; the keypad is disabled
    private(set) var isLockedOut = false

    @ObservationIgnored private let checkPasscodeUseCase: CheckPasscodeUseCase
    @ObservationIgnored private let onUnlocked: () -> Void

    init(checkPasscodeUseCase: CheckPasscodeUseCase, onUnlocked: @escaping () -> Void) {
        self.checkPasscodeUseCase = checkPasscodeUseCase
        self.onUnlocked = onUnlocked
    }

    // The view calls this when the 6th digit is typed, like the iOS lock screen
    func passcodeEntered(_ passcode: String) async {
        let result = await checkPasscodeUseCase.execute(passcode: passcode)

        // Never log the digits themselves
        switch result {
        case .success(.correct):
            message = ""
            onUnlocked()
        case .success(.wrong(let triesLeft)):
            AppLogger.access.info("Wrong passcode, \(triesLeft) tries left")
            message = "Wrong passcode. \(triesLeft) tries left."
        case .success(.lockedOut(let wait)):
            AppLogger.access.info("Passcode locked out")
            isLockedOut = true
            let minutes = Int(wait.components.seconds / 60)
            message = "Too many tries. Try again in \(minutes) min."
        case .failure(let error):
            AppLogger.access.error("Check passcode failed: \(String(reflecting: error))")
            message = "Couldn’t check the passcode. Try again."
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

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/PasscodeUnlock/PasscodeUnlockScreen.swift`

<b>Explain</b> · Keeps `code` for the keypad; the view model checks it.

<b>Think</b>

- Why does `code` stay in the view while the check moves to the view model?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- The keypad’s digits are view state; checking them is logic.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `@State private var viewModel`, `@State private var code`, `init(onUnlocked:)`, `Container.shared.checkPasscodeUseCase()`; add `import FactoryKit`.

</details>

<details>
<summary><b>Code</b></summary>

```swift
    // was: var onComplete: (String) -> Void
    @State private var viewModel: PasscodeUnlockViewModel
    @State private var code = ""

    init(onUnlocked: @escaping () -> Void) {
        let model = PasscodeUnlockViewModel(
            checkPasscodeUseCase: Container.shared.checkPasscodeUseCase(),
            onUnlocked: onUnlocked
        )
        _viewModel = State(initialValue: model)
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

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Access/PasscodeUnlock/PasscodeUnlockScreen.swift` *(continued)*

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
import FactoryKit
import Inject
import SwiftUI

struct RootView: View {
    @ObserveInjection var inject
    @Environment(\.scenePhase) private var scenePhase
    @State private var splashVM = /* … */
    @State private var rootVM = RootViewModel(/* use case + clock from Container.shared */)

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
import FactoryKit
import Inject
import SwiftUI

struct RootView: View {
    @ObserveInjection var inject
    // foreground / inactive / background, given by SwiftUI
    @Environment(\.scenePhase) private var scenePhase

    @State private var splashVM = SplashViewModel(
        sequence: StartupSequence(steps: [])
    )
    @State private var rootVM = RootViewModel(
        loadSettingsUseCase: Container.shared.loadAccessSettingUseCase(),
        clock: Container.shared.clock()
    )

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
        switch splashVM.state {
        case .ready:
            accessFlow
                .task {
                    await rootVM.load()
                }
        case .running, .failed:
            SplashScreen(viewModel: splashVM)
        }
    }

    @ViewBuilder private var accessFlow: some View {
        switch rootVM.phase {
        case .loading:
            ProgressView()
        case .welcome:
            SignInScreen(onFinished: {
                rootVM.welcomeFinished()
            })
        case .faceIDLock:
            FaceIDLockScreen(onUnlocked: {
                rootVM.unlocked()
            }, onUsePasscode: {
                rootVM.usePasscode()
            })
        case .passcodeLock:
            PasscodeUnlockScreen(onUnlocked: {
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
import Core
import DomainLayer
import Observation
import os

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

    @ObservationIgnored private let loadSettingsUseCase: LoadAccessSettingUseCase
    @ObservationIgnored private let saveSettingsUseCase: SaveAccessSettingUseCase
    @ObservationIgnored private var settings: AccessSetting?

    init(loadSettingsUseCase: LoadAccessSettingUseCase, saveSettingsUseCase: SaveAccessSettingUseCase) {
        self.loadSettingsUseCase = loadSettingsUseCase
        self.saveSettingsUseCase = saveSettingsUseCase
    }

    func load() async {
        switch await loadSettingsUseCase.execute() {
        case .success(let loaded):
            settings = loaded
            isLockOn = loaded.isLockOn
            isFaceIDOn = loaded.isFaceIdOn
            lockAfter = loaded.lockAfterTime
        case .failure(let error):
            AppLogger.access.error("Load app lock settings failed: \(String(reflecting: error))")
        }
    }

    // Saved when the screen closes
    func save() async {
        guard var updated = settings else {
            return
        }

        updated.isLockOn = isLockOn
        updated.isFaceIdOn = isFaceIDOn
        updated.lockAfterTime = lockAfter
        switch await saveSettingsUseCase.execute(setting: updated) {
        case .success:
            settings = updated
        case .failure(let error):
            AppLogger.access.error("Save app lock settings failed: \(String(reflecting: error))")
        }
    }
}
```

</details>

<b>Try</b>

- Set *Lock after* to **Immediately**, go Home and straight back: locked? Which methods made that happen?

---

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Settings/AppLock/AppLockScreen.swift`

<b>Explain</b> · Reads and saves the settings through `AppLockViewModel`.

<b>Think</b>

- `ForEach(lockAfterOptions, id: \.self)` loses its `id:` argument. Why does `Identifiable` make it unnecessary?

| In `AppLockScreen` | Change to |
|---|---|
| top of the file | `import FactoryKit` |
| `@State isLockOn / isFaceIDOn / lockAfter` and `lockAfterOptions` | `@State private var viewModel = AppLockViewModel(loadSettingsUseCase: Container.shared.loadAccessSettingUseCase(), saveSettingsUseCase: Container.shared.saveAccessSettingUseCase())` |
| `toggleRow("Lock app", isOn: $isLockOn)` | `toggleRow("Lock app", isOn: $viewModel.isLockOn)` (same for Face ID) |
| `ForEach(lockAfterOptions, id: \.self)` | `ForEach(viewModel.lockAfterOptions)`; radio on `viewModel.lockAfterTime == option.value`; tap sets `viewModel.lockAfterTime = option.value` |
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

- `enum Stage`, a computed `var title: String`, `private let setPasscodeUseCase: SetPasscodeUseCase` through `init`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import DomainLayer
import Observation

@MainActor @Observable
final class SetPasscodeViewModel {
    enum Stage { /* enter, confirm */ }
    private(set) var stage: Stage = .enter
    private(set) var message = ""
    // injected setPasscodeUseCase; firstEntry; onDone

    init(setPasscodeUseCase: SetPasscodeUseCase, onDone: @escaping () -> Void) { }

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
import Core
import DomainLayer
import Observation
import os

@MainActor @Observable
final class SetPasscodeViewModel {
    // Enter once, then again to confirm
    enum Stage {
        case enter
        case confirm
    }

    private(set) var stage: Stage = .enter
    private(set) var message = ""

    @ObservationIgnored private let setPasscodeUseCase: SetPasscodeUseCase
    @ObservationIgnored private var firstEntry = ""
    @ObservationIgnored private let onDone: () -> Void

    init(setPasscodeUseCase: SetPasscodeUseCase, onDone: @escaping () -> Void) {
        self.setPasscodeUseCase = setPasscodeUseCase
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
                switch await setPasscodeUseCase.execute(passcode: passcode) {
                case .success:
                    onDone()
                case .failure(let error):
                    AppLogger.access.error("Set passcode failed: \(String(reflecting: error))")
                    firstEntry = ""
                    message = "Couldn’t save the passcode. Try again."
                    stage = .enter
                }
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

<b>File</b> · <b class="tag-edit">Edit</b> · `SiteLog/Presentation/Settings/SetPasscode/SetPasscodeScreen.swift`

<b>Explain</b> · Hands the typed digits to `SetPasscodeViewModel`.

<b>Think</b>

- This screen and A3 both read 6 digits. Which parts of A3’s wiring can you reuse?

| In `SetPasscodeScreen` | Change to |
|---|---|
| top of the struct | `import FactoryKit`; `@State private var viewModel: SetPasscodeViewModel` + `init(onDone:)` like A3, with `Container.shared.setPasscodeUseCase()` |
| `Text("Enter a 6-digit passcode")` | `Text(viewModel.title)`; add `Text(viewModel.message)` under the dots |
| `.onChange(of: code)` | at 6 digits: `Task { await viewModel.passcodeEntered(newValue); code = "" }` |
| `AppLockScreen` | `SetPasscodeScreen(onDone: { isSetPasscodeShown = false })` |

<b>Try</b>

- Wire it up without reading the table, then compare.

</dd></dl>
</details>

<details open>
<summary><strong>3.8 Check</strong></summary>
<dl><dd>

| Step | Expect |
|---|---|
| ⌘R | Startup → A2 → **Continue offline** → A1 → in-memory Face ID unlocks after 0.5 s → tabs |
| Settings → App lock → Unlock with Face ID off; Home, wait > 10 s, reopen | A3; 5 wrong tries lock the keypad; `123456` unlocks |
| Home (⇧⌘H), wait > 10 s, reopen | Locked again; the app switcher shows the overlay |
| Settings → App lock → Change passcode | Enter twice; the new passcode unlocks A3 |
| Dev menu → **Reset the app** | Back on A2 |

</dd></dl>
</details>

</dd></dl>

## 4. Real data — Keychain and Face ID

<dl><dd>

- **Goal:** `AccessRepositoryImpl` keeps its type and methods, but its values move from memory to Keychain, `UserDefaults` and Face ID; screens, view models and use cases do not change.
- **Spec:** [07.2](../feature-docs/04-reporting-security.md#072-app-lock)

| Action | File | Holds |
|---|---|---|
| <b class="tag-new">New</b> | `DataLayer/DataSources/Local/Keychain/AccessLocalDataSource.swift` | Protocol: read / write settings, passcode hash, lockout counter; returns records, never entities |
| <b class="tag-new">New</b> | `DataLayer/DataSources/Local/Keychain/AccessLocalDataSourceImpl.swift` | Settings in `UserDefaults`; passcode hash and lockout counter in Keychain, `.whenUnlockedThisDeviceOnly` |
| <b class="tag-new">New</b> | `Core/Crypto/PasscodeHasher.swift` | `public`: PBKDF2-SHA256 with a 16-byte random salt; compare without storing the passcode |
| <b class="tag-new">New</b> | `PlatformKit/Biometrics/BiometricAuthenticator.swift` | `BiometricAuthenticating` protocol + `LAContext` type, biometry-change detection |
| <b class="tag-replace">Replace</b> | `DataLayer/Repositories/AccessRepositoryImpl.swift` | Same type and methods: calls `AccessLocalDataSource` and `BiometricAuthenticating`, maps records to entities, catches their errors → `.failure(AccessError)`; `reset()` clears them |
| <b class="tag-edit">Edit</b> | `App/DI/DataSourcesDI.swift`, `PlatformDI.swift`, `RepositoriesDI.swift` | Registers the data source and the authenticator, passes them to `AccessRepositoryImpl(…)` |

#### Steps

<dl><dd>

1. Add `INFOPLIST_KEY_NSFaceIDUsageDescription` in `project.yml`, run `xcodegen`.
2. Lockout counter survives relaunch; biometry change turns Face ID off.
3. Forgot passcode: device passcode check (`LAContext` `.deviceOwnerAuthentication`), then S5.
4. Register the data source in `DataSourcesDI`, the authenticator in `PlatformDI`, pass both in `RepositoriesDI`; no other registration changes.

</dd></dl>

#### Done when

<dl><dd>

- Relaunch keeps the passcode, settings and lockout

</dd></dl>

</dd></dl>

## Tests (after the feature works)

<dl><dd>

<b>File</b> · <b class="tag-new">New</b> · `SiteLogTests/Doubles/StubAccessRepository.swift`

<b>Explain</b> · Test double for `AccessRepository`: answers with fixed values, never touches Keychain. Test targets are the only place doubles live.

<details>
<summary><b>Code</b></summary>

```swift
import DomainLayer

actor StubAccessRepository: AccessRepository {
    private let check: PasscodeCheck
    private var settings = AccessSetting(
        isShowWelcomeScreen: true,
        isLockOn: true,
        isFaceIdOn: false,
        lockAfterTime: .seconds(10)
    )

    init(check: PasscodeCheck = .correct) {
        self.check = check
    }

    func loadAccessSetting() -> Result<AccessSetting, AccessError> {
        return .success(settings)
    }

    func saveAccessSetting(newSetting: AccessSetting) -> Result<Void, AccessError> {
        settings = newSetting
        return .success(())
    }

    func markWelcomeScreen() -> Result<Void, AccessError> {
        settings.isShowWelcomeScreen = true
        return .success(())
    }

    func checkPasscode(inputPasscode: String) -> Result<PasscodeCheck, AccessError> {
        return .success(check)
    }

    func setPasscode(newPasscode: String) -> Result<Void, AccessError> {
        return .success(())
    }

    func unlockWithBiometrics() -> Result<Bool, AccessError> {
        return .success(true)
    }

    #if DEBUG
    func resetAllData() {}
    func seedSampleData() {}
    #endif
}
```

</details>

---

<b>File</b> · <b class="tag-new">New</b> · `SiteLogTests/Access/PasscodeUnlockViewModelTests.swift`

<b>Explain</b> · Correct passcode unlocks; a wrong one shows the tries left.

<b>Think</b>

- The view model test must not touch Keychain or the container. What can stand in for `AccessRepository`, and where may that type live?

<details open>
<summary><b>Hint 1 · Idea</b></summary>

- A small test double in the test target (`StubAccessRepository`) answers `checkPasscode` with a fixed result; build the use case on it, pass it to the view model’s `init`, one `passcodeEntered` call; check the closure and the message.

</details>

<details open>
<summary><b>Hint 2 · APIs</b></summary>

- `@MainActor @Suite`, `CheckPasscodeUseCase(repository: StubAccessRepository(check: …))`, a `var didUnlock` set by the closure, `#expect`. No container, no `FactoryTesting`.

</details>

<details open>
<summary><b>Hint 3 · Skeleton</b></summary>

```swift
import DomainLayer
import Testing
@testable import SiteLog

@MainActor
@Suite
struct PasscodeUnlockViewModelTests {
    @Test func correctPasscodeUnlocks() async {
        // 1. use case on a stub that answers .correct
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
import DomainLayer
import Testing
@testable import SiteLog

@MainActor
@Suite
struct PasscodeUnlockViewModelTests {
    @Test func correctPasscodeUnlocks() async {
        let checkPasscodeUseCase = CheckPasscodeUseCase(repository: StubAccessRepository(check: .correct))
        var didUnlock = false
        let viewModel = PasscodeUnlockViewModel(checkPasscodeUseCase: checkPasscodeUseCase, onUnlocked: { didUnlock = true })

        await viewModel.passcodeEntered("123456")

        #expect(didUnlock)
    }

    @Test func wrongPasscodeShowsTriesLeft() async {
        let checkPasscodeUseCase = CheckPasscodeUseCase(repository: StubAccessRepository(check: .wrong(triesLeft: 4)))
        var didUnlock = false
        let viewModel = PasscodeUnlockViewModel(checkPasscodeUseCase: checkPasscodeUseCase, onUnlocked: { didUnlock = true })

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
- `AccessRepositoryImpl` (DataLayer tests, real storage under a test Keychain service): hash round-trip, wrong passcode rejected, lockout survives relaunch, biometry change turns Face ID off

</dd></dl>

## Feature done

<dl><dd>

| Check | How |
|---|---|
| Demo | Lock on device: Face ID, passcode, re-lock after *Lock after*, app switcher overlay |
| Tests | `bundle exec fastlane test` green |
| Roadmap | F01 steps ticked |

</dd></dl>
