//
//  PlanViewerView.swift
//  SiteLog
//
//  M4 · Plan viewer with pins; tap a pin → M5 pin preview sheet.
//

import DesignSystem
import Inject
import SwiftUI

struct PlanViewerView: View {
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
                Menu("Layers", systemImage: "square.3.layers.3d") {
                    Button("Open issues") {}
                    Button("Closed issues") {}
                    Button("Photos") {}
                }
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            HStack {
                DSStatusMarker(kind: .critical, text: "1 critical")
                Spacer()
                DSStatusMarker(kind: .major, text: "2 major")
                Spacer()
                DSStatusMarker(kind: .minor, text: "1 minor")
                Spacer()
                DSStatusMarker(kind: .resolved, text: "2 closed")
            }
            Text("Press and hold to drop a pin")
                .font(DSFont.footnote)
                .foregroundStyle(DSColor.textTertiary)
        }
        .sheet(item: $selectedPin) { pin in
            PinPreviewView(pin: pin)
                .presentationDetents([.height(200)])
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        PlanViewerView(plan: FakeData.plans[0])
    }
}
