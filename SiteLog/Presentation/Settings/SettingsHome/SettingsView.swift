// S1 · Settings

import DesignSystem
import Inject
import SwiftUI

struct SettingsView: View {
    @ObserveInjection var inject

    @State private var isDeleteAlertShown = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                NavigationLink {
                    AccountView()
                } label: {
                    DSListRow(title: FakeData.inspector, subtitle: "Synced 2 minutes ago · iPhone and iPad", showsChevron: true) {
                        avatar
                    }
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: "On site")
                    link("Laser meter", value: "DISTO D2") { DevicesView() }
                    DSDivider()
                    link("Quick phrases", value: "18") { QuickPhrasesPlaceholder() }
                    DSDivider()
                    link("Report letterhead", value: nil) { BrandingView() }
                }

                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: "Privacy")
                    link("App lock", value: "Face ID · 5 min") { AppLockView() }
                }

                VStack(spacing: 0) {
                    link("Diagnostics", value: nil) { DiagnosticExportView() }
                    DSDivider()
                    Button {
                        isDeleteAlertShown = true
                    } label: {
                        Text("Delete account")
                            .font(DSFont.body)
                            .foregroundStyle(DSColor.critical)
                            .frame(maxWidth: .infinity, minHeight: DSSize.rowMinHeight, alignment: .leading)
                            .padding(.horizontal, DSSpacing.regular)
                    }
                }

                #if DEBUG
                DevMenuSection()
                #endif
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
        .navigationTitle("Settings")
        .alert("Delete your account?", isPresented: $isDeleteAlertShown) {
            Button("Delete Account", role: .destructive) {}
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("We’ll remove the cloud copies of 3 projects and 1,284 photos within 30 days. What’s on this iPhone stays until you delete the app.")
        }
        .enableInjection()
    }

    private var avatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .font(DSFont.largeTitle)
            .foregroundStyle(DSColor.textTertiary)
    }

    private func link<Destination: View>(
        _ title: String,
        value: String?,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            DSListRow(title: title, value: value, showsChevron: true)
        }
        .buttonStyle(.plain)
    }
}

// Quick phrases editor has no mockup yet
private struct QuickPhrasesPlaceholder: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(FakeData.quickPhrases, id: \.self) { phrase in
                    DSListRow(title: phrase)
                    DSDivider()
                }
            }
        }
        .navigationTitle("Quick phrases")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
