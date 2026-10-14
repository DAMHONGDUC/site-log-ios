import SwiftUI

enum SettingsRoute: Hashable {
    case account
    case devices
    case quickPhrases
    case appLock
    case storageCleanup
}

extension View {
    func settingsDestinations() -> some View {
        navigationDestination(for: SettingsRoute.self) { route in
            switch route {
            case .account:
                AccountScreen()
            case .devices:
                DevicesScreen()
            case .quickPhrases:
                QuickPhrasesScreen()
            case .appLock:
                AppLockScreen()
            case .storageCleanup:
                StorageCleanupScreen()
            }
        }
    }
}
