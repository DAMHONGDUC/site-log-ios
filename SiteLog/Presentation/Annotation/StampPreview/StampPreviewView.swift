// M2 · Share stamped photo

import SystemDesign
import Inject
import SwiftUI

struct StampPreviewView: View {
    @ObserveInjection var inject

    @State private var showsDate = true
    @State private var showsRoom = true
    @State private var showsMarkup = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                SitePhoto(variant: 0, showsCrack: true)
                    .frame(height: 300)
                    .overlay(alignment: .bottom) {
                        stampStrip
                    }

                Text("Time checked against the network (within 2 s) and GPS (±6 m), so the stamp can be trusted.")
                    .font(SDFont.footnote)
                    .foregroundStyle(SDColor.textSecondary)
                    .padding(.horizontal, SDSpacing.regular)

                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    SDSectionHeader(title: "Stamp shows")
                    toggleRow("Date and time", isOn: $showsDate)
                    SDDivider()
                    toggleRow("Project and room", isOn: $showsRoom)
                    SDDivider()
                    toggleRow("My markup", isOn: $showsMarkup)
                }
            }
        }
        .background(SDColor.canvas)
        .navigationTitle("Share photo")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            ShareLink(item: "Verify at sitelog.app/v/7F3K-92QD") {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.sd(.primary))
        }
        .enableInjection()
    }

    private var stampStrip: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showsDate {
                Text("30 Sep 2026 10:42:18 +07 · Riverside Tower B")
            }
            if showsRoom {
                Text("Level 7 › 7A › Living room · 10.7297, 106.7215")
            }
            Text("Verify at sitelog.app/v/7F3K-92QD")
        }
        .font(SDFont.code)
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
        .background(Color.black.opacity(0.72))
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .tint(SDColor.success)
            .frame(minHeight: SDSize.rowMinHeight)
            .padding(.horizontal, SDSpacing.regular)
    }
}

#Preview {
    NavigationStack {
        StampPreviewView()
    }
}
