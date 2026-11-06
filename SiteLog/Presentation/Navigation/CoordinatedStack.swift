import SwiftUI

// A NavigationStack with its own coordinator and every feature's destinations registered
struct CoordinatedStack<Root: View>: View {
    @State private var coordinator = NavigationCoordinator()
    @ViewBuilder let root: () -> Root

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            root()
                .appDestinations()
        }
        .environment(\.coordinator, coordinator)
    }
}
