# 0006 — Swift Testing + swift-snapshot-testing + FactoryTesting

Status: Accepted · 2026-09-30 · Strategy: [testing.md](../testing.md)

## Context

Domain logic, view models and SwiftUI screens need fast tests that run on CI without a device, and
screens need a guard against visual regressions in light, dark and large Dynamic Type.

## Decision

| Need | Library |
|---|---|
| Unit tests | Swift Testing (`@Test`, `#expect`) |
| View snapshots | [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) 1.x |
| DI isolation | `FactoryTesting` — `@Suite(.container)` |
| UI flows | XCUITest, smoke paths only |

## Rejected

| Option | Why not |
|---|---|
| XCTest for new unit tests | Swift Testing is the current Apple default; XCTest kept only for XCUITest |
| ViewInspector | Tests view internals; breaks on SwiftUI changes, misses real rendering |
| Quick/Nimble | Extra DSL on top of Swift Testing |

## Consequences

- Snapshot references are committed; record on one simulator model and OS, pinned in CI.
