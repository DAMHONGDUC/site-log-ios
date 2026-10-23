// M4 · Plan viewer

import DesignSystem
import Inject
import SwiftUI

struct PlanViewerScreen: View {
    @ObserveInjection var inject

    let plan: FakePlan

    @State private var selectedPin: FakePin?

    var body: some View {
        PlanDrawing(pins: FakeData.pins) { pin in
            selectedPin = pin
        }
        .navigationTitle(plan.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("plans.planViewer.layers", systemImage: "square.3.layers.3d") {
                    Button("plans.planViewer.openIssues") {}
                    Button("plans.planViewer.closedIssues") {}
                    Button("plans.planViewer.photos") {}
                }
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            HStack {
                DSStatusMarker(
                    kind: .critical,
                    text: String(localized: "plans.planViewer.1Critical")
                )
                Spacer()
                DSStatusMarker(kind: .major, text: String(localized: "plans.planViewer.2Major"))
                Spacer()
                DSStatusMarker(kind: .minor, text: String(localized: "plans.planViewer.1Minor"))
                Spacer()
                DSStatusMarker(kind: .resolved, text: String(localized: "plans.planViewer.2Closed"))
            }
            Text("plans.planViewer.pressAndHoldToDropAPin")
                .modifier(DSTextStyle.footnote)
                .foregroundStyle(DSColor.textTertiary)
        }
        .sheet(item: $selectedPin) { pin in
            PinPreviewScreen(pin: pin)
                .presentationDetents([.height(200)])
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        PlanViewerScreen(plan: FakeData.plans[0])
    }
}
