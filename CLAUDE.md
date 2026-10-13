# SiteLog rules

Index of the project rules. The detail lives in [00-overview.md](docs/feature-docs/00-overview.md); this file only points to it. Apply every rule to new code, existing code and docs.

## Architecture

- Layers and folders: [§4.1 Repo layout](docs/feature-docs/00-overview.md#41-repo-layout), [§4.2 Layers](docs/feature-docs/00-overview.md#42-layers-and-dependency-rules).
- Domain: `Entities/<Feature>/`, `UseCases/<Feature>/` (one use case per file), `Repositories/` flat for every boundary protocol.
- Data: `Repositories/`, `DataSources/Local/` and `Remote/` (only data source protocols + their `Impl`s), `Models/Local/` (`@Model`, `Schema/`) and `Models/Remote/` (DTOs), `Mappers/`.
- PlatformKit: system services (permissions, camera, Bluetooth, Face ID…) and standalone engines on system APIs (`HTTPClient`, `UploadKit`, `Realtime`): [D11](docs/feature-docs/00-overview.md#d11--data-sources-in-datalayer-platformkit-for-system-services).
- PlatformKit is a library: generic, no Domain / Data types or business rules; only DataLayer wraps it and maps its records and errors: [D16](docs/feature-docs/00-overview.md#d16--platformkit-is-a-library-not-a-ring).
- Core: `Logger/`, `Clock/`, `Crypto/` (`PasscodeHasher`, `FileHasher`): helpers shared across layers.
- Presentation: a feature with 2+ screens gets one folder per screen.

## Code

- Naming: `<Protocol>Impl` for every implementation in DataLayer (`AccessRepositoryImpl`, `AccessLocalDataSourceImpl`), `<Noun>Model`, `<Noun>DTO`, `<Noun>Mapper`: [§7 Conventions](docs/feature-docs/00-overview.md#7-conventions).
- Errors: data sources and PlatformKit `throws`; repositories catch and return `Result<T, <Feature>Error>`; view models `switch` the result: [§4.6](docs/feature-docs/00-overview.md#46-error-handling).
- No fake repositories: the fake-data step writes the real `Impl` on in-memory values; the real-data step replaces its insides. Test doubles live only in test targets: [§7 Adding a feature](docs/feature-docs/00-overview.md#7-conventions).
- DI: view models take use cases through `init` and never import `FactoryKit`; views build them with `Container.shared`: [D14](docs/feature-docs/00-overview.md#d14--view-models-take-use-cases-through-init).
- `any P` for a protocol used as a type.
- Package types the app uses are `public`, with a `public init`.
- Format: `.swift-format` (one argument per line when wrapped) and SwiftLint; zero warnings.
- Comments: only when the code can't say it, one short plain line; no file-header blocks.
- Logging: every action and every `catch` logs through `AppLogger`; never `print`.
- Dependencies: only well-known, maintained packages (Swift Package Index), added through `project.yml`.

## Process

- Tests only after a feature works end to end.
- Docs: short, bullets and tables, contents at the top; specs in `docs/feature-docs/`, one guide per feature in `docs/feature-guide/`; after editing any `.md`, run `python3 Tools/Docs/indent-md.py`.
- Guide code: written for a Swift beginner (one idea per line, explicit `if` / `switch`); every new file gets a purpose of at most 2 lines.
- Xcode project changes go through `project.yml` (XcodeGen), never the Xcode UI.
