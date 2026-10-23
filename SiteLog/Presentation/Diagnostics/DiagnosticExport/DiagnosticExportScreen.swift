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
                        Text("diagnostics.diagnosticExport.all1284PhotosCheckOut")
                            .modifier(DSTextStyle.headline)
                    }
                    Text(
                        "diagnostics.diagnosticExport.fingerprintsMatchNothingChangedSinceCaptureChecked902"
                    )
                    .modifier(DSTextStyle.subhead)
                    .foregroundStyle(DSColor.textSecondary)
                    .padding(.leading)
                }
                .padding(.horizontal, DSSpacing.spacing16)

                VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
                    Text("diagnostics.diagnosticExport.storage")
                        .modifier(DSTextStyle.section)
                    storageBar
                    Text(
                        "diagnostics.diagnosticExport.41GbWaitingToUpload16GbAlreadyBackedUp12GbFree"
                    )
                    .modifier(DSTextStyle.footnote)
                    .foregroundStyle(DSColor.textSecondary)
                }
                .padding(.horizontal, DSSpacing.spacing16)

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(
                        title: String(localized: "diagnostics.diagnosticExport.thisIphone")
                    )
                    DSListRow(
                        title: String(localized: "diagnostics.diagnosticExport.backgroundUploads"),
                        value: String(localized: "diagnostics.diagnosticExport.on")
                    )
                    DSDivider()
                    DSListRow(
                        title: String(localized: "diagnostics.diagnosticExport.lowPowerMode"),
                        value: String(localized: "diagnostics.diagnosticExport.off")
                    )
                    DSDivider()
                    DSListRow(
                        title: String(localized: "diagnostics.diagnosticExport.liveProgress"),
                        value: String(localized: "diagnostics.diagnosticExport.polling")
                    )
                }
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("diagnostics.diagnosticExport.diagnostics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            Button("diagnostics.diagnosticExport.freeUp16Gb") {
                coordinator.push(SettingsRoute.storageCleanup)
            }
            .buttonStyle(.sd(.secondary))

            ShareLink(item: "sitelog-diagnostics.zip") {
                Text("diagnostics.diagnosticExport.sendDiagnosticsToSupport")
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
