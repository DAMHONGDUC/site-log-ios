// U3 · Diagnostics

import SystemDesign
import Inject
import SwiftUI

struct DiagnosticExportView: View {
    @ObserveInjection var inject

    @State private var isCleanupShown = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    HStack(spacing: SDSpacing.small) {
                        SDStatusMarker(kind: .resolved)
                        Text("All 1,284 photos check out")
                            .font(SDFont.headline)
                    }
                    Text("Fingerprints match, nothing changed since capture. Checked 9:02.")
                        .font(SDFont.subhead)
                        .foregroundStyle(SDColor.textSecondary)
                        .padding(.leading)
                }
                .padding(.horizontal, SDSpacing.regular)

                VStack(alignment: .leading, spacing: SDSpacing.small) {
                    Text("Storage")
                        .font(SDFont.section)
                    storageBar
                    Text("4.1 GB waiting to upload · 1.6 GB already backed up · 12 GB free")
                        .font(SDFont.footnote)
                        .foregroundStyle(SDColor.textSecondary)
                }
                .padding(.horizontal, SDSpacing.regular)

                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    SDSectionHeader(title: "This iPhone")
                    SDListRow(title: "Background uploads", value: "On")
                    SDDivider()
                    SDListRow(title: "Low Power Mode", value: "Off")
                    SDDivider()
                    SDListRow(title: "Live progress", value: "Polling")
                }
            }
            .padding(.vertical, SDSpacing.small)
        }
        .background(SDColor.canvas)
        .navigationTitle("Diagnostics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            Button("Free up 1.6 GB") {
                isCleanupShown = true
            }
            .buttonStyle(.sd(.secondary))

            ShareLink(item: "sitelog-diagnostics.zip") {
                Text("Send diagnostics to support")
            }
            .buttonStyle(.sd(.ghost))
        }
        .navigationDestination(isPresented: $isCleanupShown) {
            StorageCleanupView()
        }
        .enableInjection()
    }

    private var storageBar: some View {
        SDProgressBar(value: 0.57)
    }
}

#Preview {
    NavigationStack {
        DiagnosticExportView()
    }
}
