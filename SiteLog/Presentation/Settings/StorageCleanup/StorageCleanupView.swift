//
//  StorageCleanupView.swift
//  SiteLog
//
//  Free up space: remove local copies of files that are already backed up.
//  No mockup yet — plain list.
//

import DesignSystem
import Inject
import SwiftUI

struct StorageCleanupView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                Text("Only files already backed up are removed from this iPhone. They stay in the cloud and in your reports.")
                    .font(DSFont.subhead)
                    .foregroundStyle(DSColor.textSecondary)
                    .padding(.horizontal, DSSpacing.regular)

                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: "Backed up", trailing: "1.6 GB")
                    ForEach(FakeData.sessions.dropFirst()) { session in
                        DSListRow(title: "Riverside · \(session.title)", subtitle: session.summary, value: "540 MB")
                        DSDivider()
                    }
                }
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
        .navigationTitle("Free up space")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            Button("Remove 1.6 GB from this iPhone") {
                dismiss()
            }
            .buttonStyle(.ds(.primary))
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        StorageCleanupView()
    }
}
