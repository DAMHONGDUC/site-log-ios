//
//  AccountView.swift
//  SiteLog
//
//  Account: who is signed in, synced devices, sign out. No mockup yet.
//

import DesignSystem
import Inject
import SwiftUI

struct AccountView: View {
    @ObserveInjection var inject

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                VStack(spacing: 0) {
                    DSListRow(title: "Name", value: FakeData.inspector)
                    DSDivider()
                    DSListRow(title: "Signed in with", value: "Apple")
                    DSDivider()
                    DSListRow(title: "Last sync", value: "2 minutes ago")
                }

                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: "Devices", trailing: "2")
                    DSListRow(title: "iPhone 16", subtitle: "This iPhone")
                    DSDivider()
                    DSListRow(title: "iPad Air", subtitle: "Last seen yesterday")
                }

                Button("Sign out") {}
                    .buttonStyle(.ds(.danger))
                    .padding(.horizontal, DSSpacing.regular)
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
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
