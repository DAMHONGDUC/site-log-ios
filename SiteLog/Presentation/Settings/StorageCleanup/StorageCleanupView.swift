import SystemDesign
import Inject
import SwiftUI

struct StorageCleanupView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                Text("Only files already backed up are removed from this iPhone. They stay in the cloud and in your reports.")
                    .font(SDFont.subhead)
                    .foregroundStyle(SDColor.textSecondary)
                    .padding(.horizontal, SDSpacing.regular)

                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    SDSectionHeader(title: "Backed up", trailing: "1.6 GB")
                    ForEach(FakeData.sessions.dropFirst()) { session in
                        SDListRow(title: "Riverside · \(session.title)", subtitle: session.summary, value: "540 MB")
                        SDDivider()
                    }
                }
            }
            .padding(.vertical, SDSpacing.small)
        }
        .background(SDColor.canvas)
        .navigationTitle("Free up space")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            Button("Remove 1.6 GB from this iPhone") {
                dismiss()
            }
            .buttonStyle(.sd(.primary))
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        StorageCleanupView()
    }
}
