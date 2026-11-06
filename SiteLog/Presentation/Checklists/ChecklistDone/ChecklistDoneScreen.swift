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
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(DSColor.success)

                    Text("checklists.checklist_done.living_room_is_done")
                        .modifier(DSTextStyle.title)

                    Text(verbatim: "19 passed, 2 failed and 1 didn’t apply. It took you 6 minutes.")
                        .modifier(DSTextStyle.body)
                        .foregroundStyle(DSColor.textSecondary)
                }
                .padding(.top)
                .padding(.horizontal, DSSpacing.spacing16)

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(
                        title: String(localized: "checklists.checklist_done.sent_to_the_issue_list")
                    )

                    Button {
                        coordinator.push(IssuesRoute.detail(issueID: FakeData.issues[1].id))
                    } label: {
                        DSListRow(
                            title: String(localized: "checklists.checklist_done.crack_by_the_skirting"),
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
                            title: String(
                                localized: "checklists.checklist_done.socket_cover_not_level"
                            ),
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
            Button("checklists.checklist_done.next_bedroom1") {
                dismiss()
            }
            .buttonStyle(.sd(.primary))

            Button("checklists.checklist_done.back_to_level7") {
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
