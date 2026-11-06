#if DEBUG

    import SwiftUI

    // Restarts the app at onboarding
    struct ResetAppAction {
        let handler: () -> Void

        func callAsFunction() {
            handler()
        }
    }

    extension EnvironmentValues {
        @Entry var resetApp = ResetAppAction(handler: {})
    }

#endif
