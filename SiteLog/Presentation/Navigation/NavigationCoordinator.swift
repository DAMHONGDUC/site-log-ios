import Observation
import SwiftUI

// One per NavigationStack (each tab): owns the path; screens push routes, never views
@MainActor @Observable
final class NavigationCoordinator {
    var path = NavigationPath()

    func push(_ route: some Hashable) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}

extension NavigationCoordinator {
    // Used only outside a NavigationStack (previews); created once instead of on every read
    static let fallback = NavigationCoordinator()
}

extension EnvironmentValues {
    @Entry var coordinator: NavigationCoordinator = .fallback
}
