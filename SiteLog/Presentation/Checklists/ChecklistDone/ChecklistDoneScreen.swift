// K4 · Checklist done

import DesignSystem
import Inject
import SwiftUI

struct ChecklistDoneScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                VStack(alignment: .leading, spacing: DSSpacing.small) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(DSColor.success)

                    Text("Living room is done.")
                        .font(DSFont.title)

                    Text("19 passed, 2 failed and 1 didn’t apply. It took you 6 minutes.")
                        .font(DSFont.body)
                        .foregroundStyle(DSColor.textSecondary)
                }
                .padding(.top)
                .padding(.horizontal, DSSpacing.regular)

                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: "Sent to the issue list")

                    Button {
                        coordinator.push(IssuesRoute.detail(issueID: FakeData.issues[1].id))
                    } label: {
                        DSListRow(
                            title: "Crack by the skirting",
                            subtitle: "Tuan’s masonry crew",
                            showsChevron: true
                        ) {
                            DSStatusMarker(kind: .major)
                        }
                    }
                    .buttonStyle(.plain)

                    DSDivider()

                    Button {
                        coordinator.push(IssuesRoute.detail(issueID: FakeData.issues[4].id))
                    } label: {
                        DSListRow(
                            title: "Socket cover not level",
                            subtitle: "Phuc Electric",
                            showsChevron: true
                        ) {
                            DSStatusMarker(kind: .minor)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .background(DSColor.canvas)
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
        ChecklistDoneScreen()
    }
}
