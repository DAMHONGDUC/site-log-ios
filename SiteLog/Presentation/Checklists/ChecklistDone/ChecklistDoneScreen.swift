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

                    Text("checklists.checklistDone.livingRoomIsDone")
                        .modifier(DSTextStyle.title)

                    Text("checklists.checklistDone.19Passed2FailedAnd1DidnTApplyItTookYou6Minutes")
                        .modifier(DSTextStyle.body)
                        .foregroundStyle(DSColor.textSecondary)
                }
                .padding(.top)
                .padding(.horizontal, DSSpacing.spacing16)

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(
                        title: String(localized: "checklists.checklistDone.sentToTheIssueList")
                    )

                    Button {
                        coordinator.push(IssuesRoute.detail(issueID: FakeData.issues[1].id))
                    } label: {
                        DSListRow(
                            title: String(localized: "checklists.checklistDone.crackByTheSkirting"),
                            subtitle: String(
                                localized: "checklists.checklistDone.tuanSMasonryCrew"
                            ),
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
                                localized: "checklists.checklistDone.socketCoverNotLevel"
                            ),
                            subtitle: String(localized: "checklists.checklistDone.phucElectric"),
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
            Button("checklists.checklistDone.nextBedroom1") {
                dismiss()
            }
            .buttonStyle(.sd(.primary))

            Button("checklists.checklistDone.backToLevel7") {
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
