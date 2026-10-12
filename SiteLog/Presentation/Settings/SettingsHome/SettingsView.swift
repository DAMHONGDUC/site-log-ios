// S1 · Settings

import SystemDesign
import Inject
import SwiftUI

struct SettingsView: View {
    @ObserveInjection var inject

    @State private var isDeleteAlertShown = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                NavigationLink {
                    AccountView()
                } label: {
                    SDListRow(title: FakeData.inspector, subtitle: "Synced 2 minutes ago · iPhone and iPad", showsChevron: true) {
                        avatar
                    }
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    SDSectionHeader(title: "On site")
                    link("Laser meter", value: "DISTO D2") { DevicesView() }
                    SDDivider()
                    link("Quick phrases", value: "18") { QuickPhrasesPlaceholder() }
                    SDDivider()
                    link("Report letterhead", value: nil) { BrandingView() }
                }

                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    SDSectionHeader(title: "Privacy")
                    link("App lock", value: "Face ID · 5 min") { AppLockView() }
                }

                VStack(spacing: 0) {
                    link("Diagnostics", value: nil) { DiagnosticExportView() }
                    SDDivider()
                    Button {
                        isDeleteAlertShown = true
                    } label: {
                        Text("Delete account")
                            .font(SDFont.body)
                            .foregroundStyle(SDColor.critical)
                            .frame(maxWidth: .infinity, minHeight: SDSize.rowMinHeight, alignment: .leading)
                            .padding(.horizontal, SDSpacing.regular)
                    }
                }

                #if DEBUG
                DevMenuSection()
                #endif
            }
            .padding(.vertical, SDSpacing.small)
        }
        .background(SDColor.canvas)
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
            .font(SDFont.largeTitle)
            .foregroundStyle(SDColor.textTertiary)
    }

    private func link<Destination: View>(
        _ title: String,
        value: String?,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            SDListRow(title: title, value: value, showsChevron: true)
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
                    SDListRow(title: phrase)
                    SDDivider()
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
