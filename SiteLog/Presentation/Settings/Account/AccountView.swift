import SystemDesign
import Inject
import SwiftUI

struct AccountView: View {
    @ObserveInjection var inject

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                VStack(spacing: 0) {
                    SDListRow(title: "Name", value: FakeData.inspector)
                    SDDivider()
                    SDListRow(title: "Signed in with", value: "Apple")
                    SDDivider()
                    SDListRow(title: "Last sync", value: "2 minutes ago")
                }

                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    SDSectionHeader(title: "Devices", trailing: "2")
                    SDListRow(title: "iPhone 16", subtitle: "This iPhone")
                    SDDivider()
                    SDListRow(title: "iPad Air", subtitle: "Last seen yesterday")
                }

                Button("Sign out") {}
                    .buttonStyle(.sd(.danger))
                    .padding(.horizontal, SDSpacing.regular)
            }
            .padding(.vertical, SDSpacing.small)
        }
        .background(SDColor.canvas)
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        AccountView()
    }
}
