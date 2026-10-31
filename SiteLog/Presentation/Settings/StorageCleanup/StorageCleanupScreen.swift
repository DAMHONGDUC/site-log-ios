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
                    "settings.storage_cleanup.backup_notice"
                )
                .modifier(DSTextStyle.subhead)
                .foregroundStyle(DSColor.textSecondary)
                .padding(.horizontal, DSSpacing.spacing16)

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(
                        title: String(localized: "settings.storage_cleanup.backed_up"),
                        trailing: "1.6 GB"
                    )
                    ForEach(FakeData.sessions.dropFirst()) { session in
                        DSListRow(
                            title: "Riverside · \(session.title)",
                            subtitle: session.summary,
                            value: "540 MB"
                        )
                        DSDivider()
                    }
                }
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("settings.storage_cleanup.free_up_space")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            Button("settings.storage_cleanup.remove_files_action") {
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
