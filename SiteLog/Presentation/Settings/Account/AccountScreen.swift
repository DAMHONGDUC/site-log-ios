import DesignSystem
import Inject
import SwiftUI

struct AccountScreen: View {
    @ObserveInjection var inject

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                VStack(spacing: DSSpacing.spacing0) {
                    DSListRow(
                        title: String(localized: "settings.account.name"),
                        value: FakeData.inspector
                    )
                    DSDivider()
                    DSListRow(
                        title: String(localized: "settings.account.signed_in_with"),
                        value: "Apple"
                    )
                    DSDivider()
                    DSListRow(
                        title: String(localized: "settings.account.last_sync"),
                        value: "2 minutes ago"
                    )
                }

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(
                        title: String(localized: "settings.account.devices"),
                        trailing: "2"
                    )
                    DSListRow(
                        title: "iPhone 16",
                        subtitle: "This iPhone"
                    )
                    DSDivider()
                    DSListRow(
                        title: "iPad Air",
                        subtitle: "Last seen yesterday"
                    )
                }

                Button("settings.account.sign_out") {}
                    .buttonStyle(.sd(.danger))
                    .padding(.horizontal, DSSpacing.spacing16)
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("settings.account.account")
        .navigationBarTitleDisplayMode(.inline)
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        AccountScreen()
    }
}
