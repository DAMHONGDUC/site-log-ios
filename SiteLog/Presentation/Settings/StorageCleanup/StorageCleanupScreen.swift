import DesignSystem
import Inject
import SwiftUI

struct StorageCleanupScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                Text(
                    "settings.storageCleanup.onlyFilesAlreadyBackedUpAreRemovedFromThisIphoneTheyStayInTheCloudAndInYourReports"
                )
                .modifier(DSTextStyle.subhead)
                .foregroundStyle(DSColor.textSecondary)
                .padding(.horizontal, DSSpacing.spacing16)

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(
                        title: String(localized: "settings.storageCleanup.backedUp"),
                        trailing: String(localized: "settings.storageCleanup.16Gb")
                    )
                    ForEach(FakeData.sessions.dropFirst()) { session in
                        DSListRow(
                            title: "Riverside · \(session.title)",
                            subtitle: session.summary,
                            value: String(localized: "settings.storageCleanup.540Mb")
                        )
                        DSDivider()
                    }
                }
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("settings.storageCleanup.freeUpSpace")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            Button("settings.storageCleanup.remove16GbFromThisIphone") {
                dismiss()
            }
            .buttonStyle(.sd(.primary))
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        StorageCleanupScreen()
    }
}
