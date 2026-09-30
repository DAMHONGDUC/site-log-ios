# 0008 — XcodeGen owns the Xcode project

Status: Accepted · 2026-09-30 · How-to: [xcodegen.md](../dev-docs/xcodegen.md)

## Context

`project.pbxproj` is hard to review and conflicts on merge. The project has several local packages,
remote packages, build settings and a scheme environment that should be readable in a diff.

## Decision

`project.yml` is the source of truth; `xcodegen generate` writes `SiteLog.xcodeproj`. Code and files
are edited in Xcode; packages, links, build settings, capabilities, targets and schemes change only
in `project.yml`.

## Rejected

| Option | Why not |
|---|---|
| Hand-maintained `.xcodeproj` | Settings hidden in the pbxproj; merge conflicts |
| Tuist | More power than one app target needs; Swift manifests and its own CLI lifecycle |

## Consequences

- A setting changed in Xcode's UI is lost on the next generate.
- Run `xcodegen generate` after pulling a change to `project.yml`.
