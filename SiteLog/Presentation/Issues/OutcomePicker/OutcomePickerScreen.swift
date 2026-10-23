// C4 · Re-check outcome

import DesignSystem
import Inject
import SwiftUI

struct OutcomePickerScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    let issue: FakeIssue

    @State private var outcome = "issues.outcomePicker.closeOutcome"

    private let outcomes: [(title: String, detail: String)] = [
        ("issues.outcomePicker.closeOutcome", "issues.outcomePicker.bothPhotosGoInTheReport"),
        ("issues.outcomePicker.notYet", "issues.outcomePicker.keepItOpenAddTodayPhoto"),
        ("issues.outcomePicker.gotWorse", "issues.outcomePicker.raiseToCritical"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                HStack {
                    beforeAfterPhoto(label: "issues.outcomePicker.august12", showsCrack: true)
                    beforeAfterPhoto(label: "issues.outcomePicker.today", showsCrack: false)
                }

                VStack(alignment: .leading) {
                    Text(issue.title)
                        .modifier(DSTextStyle.headline)
                    Text(
                        String.localizedStringWithFormat(
                            String(localized: "issues.outcomePicker.assigneeAndOpenedDate"),
                            issue.assignee
                        )
                    )
                    .modifier(DSTextStyle.subhead)
                    .foregroundStyle(DSColor.textSecondary)
                }
                .padding(.horizontal, DSSpacing.spacing16)

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(title: String(localized: "issues.outcomePicker.hasItBeenFixed"))

                    ForEach(outcomes, id: \.title) { item in
                        Button {
                            outcome = item.title
                        } label: {
                            DSListRow(
                                title: NSLocalizedString(item.title, comment: ""),
                                subtitle: NSLocalizedString(item.detail, comment: "")
                            ) {
                                DSRadioMark(isOn: outcome == item.title)
                            }
                        }
                        .buttonStyle(.plain)

                        DSDivider()
                    }
                }
            }
        }
        .background(DSColor.canvas)
        .navigationTitle(
            String.localizedStringWithFormat(
                String(localized: "issues.outcomePicker.issueNumber"),
                issue.number
            )
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("issues.outcomePicker.close", systemImage: "xmark") {
                    dismiss()
                }
            }
        }
        .bottomDock {
            Button("issues.outcomePicker.save") {
                dismiss()
            }
            .buttonStyle(.sd(.primary))
        }
        .enableInjection()
    }

    private func beforeAfterPhoto(label: String, showsCrack: Bool) -> some View {
        VStack {
            SitePhoto(variant: issue.photoVariant, showsCrack: showsCrack)
                .aspectRatio(3 / 4, contentMode: .fit)
            Text(NSLocalizedString(label, comment: ""))
                .modifier(DSTextStyle.footnote)
        }
    }
}

#Preview {
    NavigationStack {
        OutcomePickerScreen(issue: FakeData.issues[1])
    }
}
