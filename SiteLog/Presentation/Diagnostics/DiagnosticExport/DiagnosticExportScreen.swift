// U3 · Diagnostics

import DesignSystem
import Inject
import SwiftUI

struct DiagnosticExportScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    HStack(spacing: DSSpacing.spacing8) {
                        DSStatusMarker(kind: .resolved)
                        Text(verbatim: "All 1,284 photos check out")
                            .modifier(DSTextStyle.headline)
                    }
                    Text(verbatim: "Fingerprints match, nothing changed since capture. Checked 9:02.")
                    .modifier(DSTextStyle.subhead)
                    .foregroundStyle(DSColor.textSecondary)
                    .padding(.leading)
                }
                .padding(.horizontal, DSSpacing.spacing16)

                VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
                    Text("diagnostics.diagnostic_export.storage")
                        .modifier(DSTextStyle.section)
                    storageBar
                    Text(verbatim: "4.1 GB waiting to upload · 1.6 GB already backed up · 12 GB free")
                    .modifier(DSTextStyle.footnote)
                    .foregroundStyle(DSColor.textSecondary)
                }
                .padding(.horizontal, DSSpacing.spacing16)

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(
                        title: String(localized: "diagnostics.diagnostic_export.this_iphone")
                    )
                    DSListRow(
                        title: String(localized: "diagnostics.diagnostic_export.background_uploads"),
                        value: String(localized: "diagnostics.diagnostic_export.on")
                    )
                    DSDivider()
                    DSListRow(
                        title: String(localized: "diagnostics.diagnostic_export.low_power_mode"),
                        value: String(localized: "diagnostics.diagnostic_export.off")
                    )
                    DSDivider()
                    DSListRow(
                        title: String(localized: "diagnostics.diagnostic_export.live_progress"),
                        value: String(localized: "diagnostics.diagnostic_export.polling")
                    )
                }
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("diagnostics.diagnostic_export.diagnostics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            Button("diagnostics.diagnostic_export.free_up16_gb") {
                coordinator.push(SettingsRoute.storageCleanup)
            }
            .buttonStyle(.sd(.secondary))

            ShareLink(item: "sitelog-diagnostics.zip") {
                Text("diagnostics.diagnostic_export.send_action")
            }
            .buttonStyle(.sd(.ghost))
        }
        .enableInjection()
    }

    private var storageBar: some View {
        DSProgressBar(value: 0.57)
    }
}

#Preview {
    NavigationStack {
        DiagnosticExportScreen()
    }
}
