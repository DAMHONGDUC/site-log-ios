# SwiftLint

SwiftLint runs on every build of the `SiteLog` target and reports lint issues as Xcode warnings.

| Tool | Owns | Config |
|---|---|---|
| `swift-format` | Formatting (layout, line length, import order) | [`.swift-format`](../../.swift-format) — see [xcode-format-on-save.md](xcode-format-on-save.md) |
| SwiftLint | Correctness and style rules that don't fight the formatter | [`.swiftlint.yml`](../../.swiftlint.yml) |

## Install

```bash
brew install swiftlint
```

## Build phase

`SiteLog` target → Build Phases → **Run SwiftLint** (after Resources):

| Condition | Behavior |
|---|---|
| Apple Silicon | Prepends `/opt/homebrew/bin` to `PATH` |
| `swiftlint` found | Runs `swiftlint` from the repo root |
| `swiftlint` missing | Emits a build warning to run `brew install swiftlint`; build continues |
| `ENABLE_USER_SCRIPT_SANDBOXING = NO` (target only) | Lets SwiftLint read the repo; with sandboxing on, the build fails with `Sandbox: swiftlint deny file-read-data` |
| `alwaysOutOfDate = 1` | Runs every build without an outputs warning |

## Rules

| Setting | Values |
|---|---|
| `excluded` | `.build`, `Packages/Core/.build`, `DerivedData` |
| `disabled_rules` | `trailing_whitespace`, `line_length`, `trailing_comma` (owned by `swift-format`) |
| `opt_in_rules` | `empty_count`, `explicit_init`, `redundant_type_annotation`, `unneeded_parentheses_in_closure_argument` |

## Run manually

```bash
swiftlint
```
