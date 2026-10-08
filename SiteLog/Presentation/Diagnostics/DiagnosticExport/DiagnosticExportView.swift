// U3 · Diagnostics

import DesignSystem
import Inject
import SwiftUI

struct DiagnosticExportView: View {
    @ObserveInjection var inject

    @State private var isCleanupShown = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    HStack(spacing: DSSpacing.small) {
                        DSStatusMarker(kind: .resolved)
                        Text("All 1,284 photos check out")
                            .font(DSFont.headline)
                    }
                    Text("Fingerprints match, nothing changed since capture. Checked 9:02.")
                        .font(DSFont.subhead)
                        .foregroundStyle(DSColor.textSecondary)
                        .padding(.leading)
                }
                .padding(.horizontal, DSSpacing.regular)

                VStack(alignment: .leading, spacing: DSSpacing.small) {
                    Text("Storage")
                        .font(DSFont.section)
                    storageBar
                    Text("4.1 GB waiting to upload · 1.6 GB already backed up · 12 GB free")
                        .font(DSFont.footnote)
                        .foregroundStyle(DSColor.textSecondary)
                }
                .padding(.horizontal, DSSpacing.regular)

                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: "This iPhone")
                    DSListRow(title: "Background uploads", value: "On")
                    DSDivider()
                    DSListRow(title: "Low Power Mode", value: "Off")
                    DSDivider()
                    DSListRow(title: "Live progress", value: "Polling")
                }
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
        .navigationTitle("Diagnostics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            Button("Free up 1.6 GB") {
                isCleanupShown = true
            }
            .buttonStyle(.ds(.secondary))

            ShareLink(item: "sitelog-diagnostics.zip") {
                Text("Send diagnostics to support")
            }
            .buttonStyle(.ds(.ghost))
        }
        .navigationDestination(isPresented: $isCleanupShown) {
            StorageCleanupView()
        }
        .enableInjection()
    }

    private var storageBar: some View {
        DSProgressBar(value: 0.57)
    }
}

#Preview {
    NavigationStack {
        DiagnosticExportView()
    }
}
