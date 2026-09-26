# Format-on-save for SwiftUI in Xcode

Auto-formats the current file with `swift-format` right before Xcode saves it, using a global
⌘S hotkey that only activates while Xcode is frontmost.

## 1. Create the format rule

From the project root:

```bash
swift-format dump-configuration > .swift-format
```

Use `swift-format dump-configuration` (hyphenated binary, installed via `brew install
swift-format`) unless the project's toolchain is Swift 6 / Xcode 16+, where `swift format
dump-configuration` (no hyphen) works as a built-in subcommand of `swift`. Check with
`swift format --help` before relying on the no-hyphen form.

Key values to set in the dumped `.swift-format` JSON:

```json
{
  "lineLength": 120,
  "indentation": { "spaces": 4 },
  "respectsExistingLineBreaks": true,
  "lineBreakBeforeEachArgument": true
}
```

Keep `respectsExistingLineBreaks: true` so multi-line SwiftUI modifier chains don't get collapsed
onto a single line.

Commit `.swift-format` to git so the rule is shared across the team.

## 2. Install Hammerspoon

```bash
brew install --cask hammerspoon
```

Grant Accessibility permission when macOS prompts for it (required for Hammerspoon to send
keystrokes and menu commands to other apps).

## 3. Find the exact Xcode menu item

Before writing the script, open **Editor → Structure** in Xcode with a Swift file focused and
copy the exact wording of the format command shown there (e.g. `Format File with 'swift-format'`
on Xcode 16+ with a `.swift-format` file at the project root). The wording varies by Xcode version
and by whether formatting comes from Xcode's built-in integration or a third-party extension —
verify it on your machine rather than assuming the string below.

## 4. Hammerspoon config

Add to `~/.hammerspoon/init.lua`:

```lua
xcodeSave = hs.hotkey.new({"cmd"}, "s", function()
  local app = hs.application.frontmostApplication()
  app:selectMenuItem({"Editor", "Structure", "Format File with 'swift-format'"})
  hs.timer.doAfter(0.25, function() app:selectMenuItem({"File", "Save"}) end)
end)

xcodeWatcher = hs.application.watcher.new(function(name, event)
  if name ~= "Xcode" then return end
  if event == hs.application.watcher.activated then xcodeSave:enable()
  elseif event == hs.application.watcher.deactivated then xcodeSave:disable() end
end):start()
```

Notes:

- `selectMenuItem` takes a table describing the full menu path, not a bare string — replace the
  three-element table above with whatever path you copied in step 3.
- If Xcode is already the frontmost app when Hammerspoon (re)loads this config, the watcher only
  fires on the next activate/deactivate transition, so the hotkey won't be enabled until you
  switch away from and back to Xcode once.

## 5. Load the config

Click the Hammerspoon menu-bar icon → **Reload Config**, then enable **Launch at Login**.

From then on, ⌘S in Xcode runs the format command first, then saves.
