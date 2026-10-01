# Code snippets

Xcode snippets for new screens. Xcode only reads user snippets from
`~/Library/Developer/Xcode/UserData/CodeSnippets/`, so they are installed per machine, not in the repo.

| Shortcut | Inserts |
|---|---|
| `view` | SwiftUI view with Inject hot reload |
| `viewvm` | `@Observable` view model (`State` enum, `onAppear()`) |

## Use

1. New empty Swift file, type `view` or `viewvm`, press Return.
2. Tab moves between placeholders; on the type name, ⌃⌘E (Edit All in Scope) renames every use.
3. One file each: `view` in `<Screen>View.swift`, `viewvm` in `<Screen>ViewModel.swift`, same folder.

## Edit or recreate

Library (⇧⌘L) → `{}` tab → search "SwiftUI View". On a new machine, recreate them from that
Library panel: type the code, select it, right-click → Create Code Snippet, set the completion to
`view` / `viewvm` and availability to Top Level.
