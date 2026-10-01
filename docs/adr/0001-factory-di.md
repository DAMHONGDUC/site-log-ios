# 0001 — Factory for dependency injection

Status: Accepted · 2026-09-30

## Context

Clean Architecture needs one place that binds `DataLayer` implementations to `Domain` protocols and
lets previews and tests swap them. A hand-written `AppDependencies` class with one `make…()` per use
case grows with every feature and needs a manual override path for each seam.

## Decision

Use [Factory](https://github.com/hmlongco/Factory) 3.x (`FactoryKit`).

- All registrations are `extension Container` in `SiteLog/App/AppDependencies.swift`.
- Data sources and stateful services are `.singleton`; use cases are unscoped.
- View models resolve **use cases only**, with `@ObservationIgnored @Injected(\.useCase)`.
- `Domain` and `DataLayer` never import `FactoryKit`.

## Rejected

| Option | Why not |
|---|---|
| Hand-written composition root | Boilerplate per use case; overrides for previews/tests hand-built each time |
| swift-dependencies (Point-Free) | Pulls in a larger ecosystem; its idioms fit TCA better than MVVM |
| Swinject | Runtime registration, failures at runtime instead of compile time |
| SwiftUI `Environment` only | Reaches views, not view models or services |

## Consequences

- Compile-time safe: a missing registration does not compile.
- Previews override in one line: `Container.shared.projectRepository { InMemoryProjectRepository() }`.
- Tests use `@Suite(.container)` (`FactoryTesting`) for an isolated container per test.
- Replacing the library touches one file plus the `@Injected` lines in view models.
