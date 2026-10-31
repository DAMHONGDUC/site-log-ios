// S1 · Settings

import DesignSystem
import Inject
import SwiftUI

struct SettingsScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    @State private var isDeleteAlertShown = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                Button(action: {
                    coordinator.push(SettingsRoute.account)
                }) {
                    DSListRow(
                        title: FakeData.inspector,
                        subtitle: "Synced 2 minutes ago · iPhone and iPad",
                        showsChevron: true,
                        leading: { avatar }
                    )
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(title: String(localized: "settings.settings.on_site"))
                    link(NSLocalizedString("settings.settings.laser_meter", comment: ""), value: "DISTO D2", to: SettingsRoute.devices)
                    DSDivider()
                    link(NSLocalizedString("settings.settings.quick_phrases", comment: ""), value: "18", to: SettingsRoute.quickPhrases)
                    DSDivider()
                    link(NSLocalizedString("settings.settings.report_letterhead", comment: ""), value: nil, to: ReportsRoute.branding)
                }

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(title: String(localized: "settings.settings.privacy"))
                    link(
                        NSLocalizedString("settings.settings.app_lock", comment: ""),
                        value: "Face ID · 5 min",
                        to: SettingsRoute.appLock
                    )
                }

                VStack(spacing: DSSpacing.spacing0) {
                    link(NSLocalizedString("settings.settings.diagnostics", comment: ""), value: nil, to: DiagnosticsRoute.export)
                    DSDivider()
                    Button(action: {
                        isDeleteAlertShown = true
                    }) {
                        Text("settings.settings.delete_account")
                            .modifier(DSTextStyle.body)
                            .foregroundStyle(DSColor.critical)
                            .frame(maxWidth: .infinity, minHeight: DSSpacing.spacing52, alignment: .leading)
                            .padding(.horizontal, DSSpacing.spacing16)
                    }
                }

                #if DEBUG
                    DevMenuSection()
                #endif
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("settings.settings.settings")
        .alert("settings.settings.delete_your_account", isPresented: $isDeleteAlertShown) {
            Button("settings.settings.delete_account2", role: .destructive, action: {})
            Button("settings.settings.cancel", role: .cancel, action: {})
        } message: {
            Text("settings.settings.delete_account_notice")
        }
        .enableInjection()
    }

    private var avatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .modifier(DSTextStyle.largeTitle)
            .foregroundStyle(DSColor.textTertiary)
    }

    private func link(_ title: String, value: String?, to route: some Hashable) -> some View {
        Button(action: {
            coordinator.push(route)
        }) {
            DSListRow(title: title, value: value, showsChevron: true)
        }
        .buttonStyle(.plain)
    }
}

// Quick phrases editor has no mockup yet
struct QuickPhrasesScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.spacing0) {
                ForEach(FakeData.quickPhrases, id: \.self) { phrase in
                    DSListRow(title: phrase)
                    DSDivider()
                }
            }
        }
        .navigationTitle("settings.settings.quick_phrases")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
