# Hot reload

Save a `.swift` file and the running simulator app updates in place, with no rebuild and no return
to the root screen. It replaces SwiftUI Previews when editing in VS Code.

```mermaid
flowchart LR
    E["Save in VS Code"] --> N["InjectionNext<br/>recompiles the file"]
    N --> A["Running app<br/>(Inject redraws the view)"]
```

## 1. Install InjectionNext

| Step | Action |
|---|---|
| 1 | Download the latest release from [InjectionNext](https://github.com/johnno1962/InjectionNext/releases) |
| 2 | Move `InjectionNext.app` to `/Applications` and open it; it lives in the menu bar |
| 3 | Menu bar icon → **...or Watch Project** → pick the repo root |

InjectionNext replaces InjectionIII; quit InjectionIII so both do not run at once.

## 2. Project setup (already done)

| Setting | Value | Owner |
|---|---|---|
| `OTHER_LDFLAGS` (Debug) | `-Xlinker -interposable` | [`project.yml`](../../project.yml) |
| `EMIT_FRONTEND_COMMAND_LINES` (Debug) | `YES` | [`project.yml`](../../project.yml) |
| Scheme env `INJECTION_PROJECT_ROOT` | `$(SRCROOT)` | [`project.yml`](../../project.yml) |
| `Inject` package | 1.6.0 | [`project.yml`](../../project.yml) |

## 3. Make a view reloadable

```swift
import Inject
import SwiftUI

struct TodoListView: View {
    @ObserveInjection var inject

    var body: some View {
        List { ... }
            .enableInjection()
    }
}
```

The `swiftview` snippet in VS Code generates this shape.

## 4. Daily use

| Step | Action |
|---|---|
| 1 | Build and run on the simulator (SweetPad, or F5 to attach the debugger) |
| 2 | Edit a view and save |
| 3 | The simulator updates; InjectionNext's menu bar icon flashes on each injection |

| Symptom | Cause / fix |
|---|---|
| Nothing changes on save | The app was built before InjectionNext started watching; rebuild once |
| Change applies but the view does not redraw | The view is missing `@ObserveInjection` or `.enableInjection()` |
| Changed a stored property or added a type | Not injectable; rebuild |
