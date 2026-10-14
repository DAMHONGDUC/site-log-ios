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

extension EnvironmentValues {
    @Entry var coordinator = NavigationCoordinator()
}
