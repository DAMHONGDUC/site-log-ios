// K4 · Checklist done

import SystemDesign
import Inject
import SwiftUI

struct ChecklistDoneView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                VStack(alignment: .leading, spacing: SDSpacing.small) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(SDColor.success)

                    Text("Living room is done.")
                        .font(SDFont.title)

                    Text("19 passed, 2 failed and 1 didn’t apply. It took you 6 minutes.")
                        .font(SDFont.body)
                        .foregroundStyle(SDColor.textSecondary)
                }
                .padding(.top)
                .padding(.horizontal, SDSpacing.regular)

                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    SDSectionHeader(title: "Sent to the issue list")

                    NavigationLink {
                        IssueDetailView(issue: FakeData.issues[1])
                    } label: {
                        SDListRow(title: "Crack by the skirting", subtitle: "Tuan’s masonry crew", showsChevron: true) {
                            SDStatusMarker(kind: .major)
                        }
                    }
                    .buttonStyle(.plain)

                    SDDivider()

                    NavigationLink {
                        IssueDetailView(issue: FakeData.issues[4])
                    } label: {
                        SDListRow(title: "Socket cover not level", subtitle: "Phuc Electric", showsChevron: true) {
                            SDStatusMarker(kind: .minor)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .background(SDColor.canvas)
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            Button("Next: Bedroom 1") {
                dismiss()
            }
            .buttonStyle(.sd(.primary))

            Button("Back to Level 7") {
                dismiss()
            }
            .buttonStyle(.sd(.ghost))
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        ChecklistDoneView()
    }
}
