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
                        title: String(localized: "settings.account.signedInWith"),
                        value: String(localized: "settings.account.apple")
                    )
                    DSDivider()
                    DSListRow(
                        title: String(localized: "settings.account.lastSync"),
                        value: String(localized: "settings.account.2MinutesAgo")
                    )
                }

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(
                        title: String(localized: "settings.account.devices"),
                        trailing: String(localized: "settings.account.2")
                    )
                    DSListRow(
                        title: String(localized: "settings.account.iphone16"),
                        subtitle: String(localized: "settings.account.thisIphone")
                    )
                    DSDivider()
                    DSListRow(
                        title: String(localized: "settings.account.ipadAir"),
                        subtitle: String(localized: "settings.account.lastSeenYesterday")
                    )
                }

                Button("settings.account.signOut") {}
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
