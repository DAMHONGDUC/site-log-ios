import SwiftUI

extension View {
    // Every feature's routes, so any screen in a stack can push any feature
    func appDestinations() -> some View {
        self
            .projectsDestinations()
            .issuesDestinations()
            .checklistsDestinations()
            .plansDestinations()
            .reportsDestinations()
            .annotationDestinations()
            .uploadsDestinations()
            .settingsDestinations()
            .diagnosticsDestinations()
    }
}
