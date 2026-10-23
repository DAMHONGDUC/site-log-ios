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
                Button {
                    coordinator.push(SettingsRoute.account)
                } label: {
                    DSListRow(
                        title: FakeData.inspector,
                        subtitle: String(
                            localized: "settings.settings.synced2MinutesAgoIphoneAndIpad"
                        ),
                        showsChevron: true
                    ) {
                        avatar
                    }
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(title: String(localized: "settings.settings.onSite"))
                    link(
                        NSLocalizedString("settings.settings.laserMeter", comment: ""),
                        value: "DISTO D2",
                        to: SettingsRoute.devices
                    )
                    DSDivider()
                    link(
                        NSLocalizedString("settings.settings.quickPhrases", comment: ""),
                        value: "18",
                        to: SettingsRoute.quickPhrases
                    )
                    DSDivider()
                    link(
                        NSLocalizedString("settings.settings.reportLetterhead", comment: ""),
                        value: nil,
                        to: ReportsRoute.branding
                    )
                }

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(title: String(localized: "settings.settings.privacy"))
                    link(
                        NSLocalizedString("settings.settings.appLock", comment: ""),
                        value: NSLocalizedString(
                            "settings.settings.faceIdFiveMinutes",
                            comment: ""
                        ),
                        to: SettingsRoute.appLock
                    )
                }

                VStack(spacing: DSSpacing.spacing0) {
                    link(
                        NSLocalizedString("settings.settings.diagnostics", comment: ""),
                        value: nil,
                        to: DiagnosticsRoute.export
                    )
                    DSDivider()
                    Button {
                        isDeleteAlertShown = true
                    } label: {
                        Text("settings.settings.deleteAccount")
                            .modifier(DSTextStyle.body)
                            .foregroundStyle(DSColor.critical)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: DSSpacing.spacing52,
                                alignment: .leading
                            )
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
        .alert("settings.settings.deleteYourAccount", isPresented: $isDeleteAlertShown) {
            Button("settings.settings.deleteAccount2", role: .destructive) {}
            Button("settings.settings.cancel", role: .cancel) {}
        } message: {
            Text(
                "settings.settings.weLlRemoveTheCloudCopiesOf3ProjectsAnd1284PhotosWithin30DaysWhatSOnThisIphoneStaysUntilYouDeleteTheApp"
            )
        }
        .enableInjection()
    }

    private var avatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .modifier(DSTextStyle.largeTitle)
            .foregroundStyle(DSColor.textTertiary)
    }

    private func link(_ title: String, value: String?, to route: some Hashable) -> some View {
        Button {
            coordinator.push(route)
        } label: {
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
        .navigationTitle("settings.settings.quickPhrases")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
