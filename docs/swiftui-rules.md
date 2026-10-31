# SwiftUI Rules

<dl><dd>

> **Small views, minimal state, logic outside the View, styles from the design system, text via keys, meaningful names.**

</dd></dl>

## View

<dl><dd>

1. **Small views, one job each.** If `body` exceeds ~50 lines, extract subviews.
2. **`body` only describes UI.** No heavy computation, no network calls, no business logic.
3. **Extract subviews as `struct`, not computed properties,** when the view has state or is reusable.
4. **No `AnyView`.** Use `@ViewBuilder` or generics.
5. **Conditional modifiers take a parameter.** Avoid wrapping modifiers in `if` (it changes the view type and loses state/animation).
   - **Write alerts in the full, labeled form.** Put each argument on its own line; use `actions:` and `message:` closures instead of trailing-closure shorthand. Inside an alert, use `Button(_:role:action:)` and write the action closure explicitly. The title is the first unlabeled argument because SwiftUI's API declares it with `_`.
     ```swift
     .alert(
         "project.delete.title", // titleKey (the API uses an unlabeled argument)
         isPresented: $isDeleteAlertShown, // Binding<Bool>
         actions: { // Returns the alert buttons
             Button(
                 "project.delete.confirm",
                 role: .destructive,
                 action: {
                     viewModel.delete()
                 }
             )
             Button(
                 "common.cancel",
                 role: .cancel,
                 action: {} // The alert closes automatically
             )
         },
         message: { // Returns the supporting message
             Text("project.delete.message")
         }
     )
     ```

</dd></dl>

## State

<dl><dd>

6. **Use the right property wrapper, and keep state as low as possible:**
   - `@State`: view-local state (should be `private`)
   - `@Binding`: child edits the parent's state
   - `@Observable` (iOS 17+) / `@StateObject`: view model
   - `@Environment`: shared dependencies
7. **Single source of truth.** Never copy state into two places.
8. **Use an `enum` for status instead of multiple loose `Bool`s** (`idle / loading / loaded / failed`).

</dd></dl>

## Architecture

<dl><dd>

9. **Views know nothing about network or database.** They only talk to the ViewModel.
10. **Dependencies come in through `init` or a DI container.** Never call singletons directly inside a View. Name stored dependency properties and local parameter variables with their role suffix: `...UseCase`, `...Repository`, or `...DataSource`. For example, use `loadSettingsUseCase`, `accessRepository`, and `accessLocalDataSource`. Preserve an existing public argument label when compatibility requires it: `init(repository accessRepository: any AccessRepository)` keeps the `repository:` call label while naming the local variable `accessRepository`.
11. **Organize modules by feature.** Each feature owns its View + ViewModel + UseCase.
12. **Keep logic out of the View so it is testable** (the ViewModel should not `import SwiftUI` if possible).

</dd></dl>

## Style and Design System

<dl><dd>

13. **Every UI uses shared `DesignSystem` tokens:** `DSColor` for every color, `DSSpacing` for spacing, dimensions, and corner radii, and `DSTextStyle` for text. Do not write `Color.*`, numeric spacing, or `.font(...)` directly in a View; add a named token when a needed value is missing.
    - `DSSpacing` is an enum namespace for spacing, corner radii, and control sizes. Names use the numeric value, such as `spacing8` for 8 points and `spacing50` for a 50-point button height. For example, `VStack(spacing: DSSpacing.spacing8) { ... }` puts 8 points between its children.
    - `DSTextStyle` lives in the `DesignSystem` package and provides fixed styles as `.modifier(DSTextStyle.body)`. `RootView` applies `body` as the default for the whole app; apply a more specific style to text that needs one. Each style sets font family, point size, weight, and line-height target. The sans family is system SF Pro; the monospaced family is SF Mono.

      | Style | Family | Size | Weight | Line height |
      | --- | --- | ---: | --- | ---: |
      | `largeTitle` | SF Pro | 34 pt | Bold | 41 pt |
      | `title` | SF Pro | 24 pt | Bold | 30 pt |
      | `pageTitle` | SF Pro | 28 pt | Bold | 34 pt |
      | `section` | SF Pro | 20 pt | Semibold | 25 pt |
      | `headline` | SF Pro | 17 pt | Semibold | 22 pt |
      | `body` | SF Pro | 17 pt | Regular | 22 pt |
      | `subhead` | SF Pro | 15 pt | Regular | 20 pt |
      | `footnote` | SF Pro | 13 pt | Regular | 18 pt |
      | `caption` | SF Pro | 10 pt | Medium | 12 pt |
      | `code` | SF Mono | 13 pt | Regular | 18 pt |
      | `figure` | SF Pro | 28 pt | Semibold | 34 pt |

      SwiftUI exposes line spacing rather than an exact line-height property. The modifier applies the token's extra leading as `lineSpacing`; single-line text keeps the same font metrics.
    - Use the closest existing token. Add a token only when the design needs a genuinely new value, and keep its value in the shared type so screens do not each define their own.
14. **Repeated styling becomes a `ViewModifier` / `ButtonStyle`.**
15. **Every view has a `#Preview` with sample data.**

</dd></dl>

## Localization

<dl><dd>

16. **Use keys for translatable UI copy; keep fixed values out of the catalog.** Put names, dates, IDs, counts, measurements, and file names directly in Presentation.
    ```swift
    Text("access.sign_in.title")                    // ✅ UI copy key
    Text(verbatim: "Riverside Tower B")             // ✅ fixed value
    Text("Seed data")                               // ❌ hard-coded UI copy
    String(localized: "access.sign_in.description") // ✅ when a String is needed
    ```
17. **Name keys by UI role, not by the displayed wording.** Use short `snake_case` segments, such as `access.sign_in.title`, `access.sign_in.description`, or `access.sign_in.benefit_1`. Store the real copy in the String Catalog.
18. **No string concatenation.** Use placeholders and plurals in the String Catalog (`Localizable.xcstrings`).
    ```swift
    Text("devmenu.finished \(name)")            // ✅ placeholder
    Text(name + " finished")                    // ❌ concatenation
    ```
19. **Models and ViewModels return keys** (`LocalizedStringResource` or `LocalizedStringKey`), not already-translated strings.
    Note: `Text(someString)` with a `String` variable is **not** localized. Only `Text("literal")` or `Text(LocalizedStringKey)` is.

</dd></dl>

## Concurrency

<dl><dd>

20. **UI runs on `@MainActor`.** Use `async/await` for heavy work, no nested callbacks.
21. **Use `.task { }` instead of `onAppear { Task { } }`** (it cancels automatically when the view disappears).

</dd></dl>

## Quality

<dl><dd>

22. **Name things by meaning:** `isLoading`, `didTapSave()`. Never `flag1`, `handle()`.
23. **Use SwiftLint + SwiftFormat in CI** so the whole team shares one style.
24. **Support Dark Mode and Accessibility** (`accessibilityLabel`) from day one. Use `DSTextStyle` for every UI text style; do not use SwiftUI's default font or a local `.font(...)` override.

---

</dd></dl>

## Example: localized `DevAction`

<dl><dd>

```swift
enum DevAction: CaseIterable, Identifiable {
    case seedData
    case deleteAllData
    case resetApp

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .seedData: "devmenu.seed.title"
        case .deleteAllData: "devmenu.deleteAll.title"
        case .resetApp: "devmenu.reset.title"
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .seedData: "devmenu.seed.subtitle"
        case .deleteAllData: "devmenu.deleteAll.subtitle"
        case .resetApp: "devmenu.reset.subtitle"
        }
    }
}
```

Developer log strings (`AppLogger`) do not need localization. Add a separate `var logName: String` for logging if needed.

---

</dd></dl>

## PR Checklist

<dl><dd>

- [ ] `body` is short, with no business logic
- [ ] State uses the right wrapper, with no duplicated source
- [ ] Status uses an `enum`, not multiple `Bool`s
- [ ] Views do not call network/database/singletons directly
- [ ] No hard-coded colors, fonts, or spacing
- [ ] UI colors, spacing, dimensions, radii, and text use `DSColor`, `DSSpacing`, and `DSTextStyle`
- [ ] No hard-coded UI strings, keys are used
- [ ] `#Preview` is present
- [ ] Accessibility labels exist for important icons/buttons

</dd></dl>
