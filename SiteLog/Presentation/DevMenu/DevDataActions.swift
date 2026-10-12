#if DEBUG

import Core
import os
import SwiftUI

protocol DevDataActions {
    func seedData() async
    func deleteAllData() async
}

// Only logs; F01 replaces it with FakeDevDataActions
struct NoopDevDataActions: DevDataActions {
    func seedData() async {
        AppLogger.devMenu.info("Seed data - not wired yet")
    }

    func deleteAllData() async {
        AppLogger.devMenu.info("Delete all data - not wired yet")
    }
}

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
