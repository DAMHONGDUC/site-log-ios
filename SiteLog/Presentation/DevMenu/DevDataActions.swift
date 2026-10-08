//
//  DevDataActions.swift
//  SiteLog
//
//  Hook for the debug dev menu. The menu only calls these methods;
//  the real work (repositories, SwiftData, Keychain, files) is wired in later.
//

#if DEBUG

import os
import SwiftUI

protocol DevDataActions {
    // Fill the app with sample projects, sessions, issues…
    func seedData() async
    // Remove every local record and file the app created
    func deleteAllData() async
}

// Placeholder until the data layer exists: only logs.
// Replace with a real implementation (e.g. registered in AppDependencies).
struct NoopDevDataActions: DevDataActions {
    func seedData() async {
        AppLogger.devMenu.info("Seed data - not wired yet")
    }

    func deleteAllData() async {
        AppLogger.devMenu.info("Delete all data - not wired yet")
    }
}

// Lets any view restart the app at onboarding: @Environment(\.resetApp) var resetApp
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
