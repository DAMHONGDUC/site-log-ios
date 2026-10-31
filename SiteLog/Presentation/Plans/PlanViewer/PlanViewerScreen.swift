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
                Menu("plans.plan_viewer.layers", systemImage: "square.3.layers.3d") {
                    Button("plans.plan_viewer.open_issues") {}
                    Button("plans.plan_viewer.closed_issues") {}
                    Button("plans.plan_viewer.photos") {}
                }
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            HStack {
                DSStatusMarker(
                    kind: .critical,
                    text: "1 critical"
                )
                Spacer()
                DSStatusMarker(kind: .major, text: "2 major")
                Spacer()
                DSStatusMarker(kind: .minor, text: "1 minor")
                Spacer()
                DSStatusMarker(kind: .resolved, text: "2 closed")
            }
            Text("plans.plan_viewer.press_and_hold_to_drop_a_pin")
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
