// C4 · Re-check outcome

import DesignSystem
import Inject
import SwiftUI

struct OutcomePickerScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    let issue: FakeIssue

    @State private var outcome = "issues.outcome_picker.close_outcome"

    private let outcomes: [(title: String, detail: String)] = [
        ("issues.outcome_picker.close_outcome", "issues.outcome_picker.both_photos_go_in_the_report"),
        ("issues.outcome_picker.not_yet", "issues.outcome_picker.keep_it_open_add_today_photo"),
        ("issues.outcome_picker.got_worse", "issues.outcome_picker.raise_to_critical"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                HStack {
                    beforeAfterPhoto(label: "12 Aug", showsCrack: true)
                    beforeAfterPhoto(label: "issues.outcome_picker.today", showsCrack: false)
                }

                VStack(alignment: .leading) {
                    Text(issue.title)
                        .modifier(DSTextStyle.headline)
                    Text(
                        String.localizedStringWithFormat(
                            String(localized: "issues.outcome_picker.assignee_and_opened_date"),
                            issue.assignee
                        )
                    )
                    .modifier(DSTextStyle.subhead)
                    .foregroundStyle(DSColor.textSecondary)
                }
                .padding(.horizontal, DSSpacing.spacing16)

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(title: String(localized: "issues.outcome_picker.has_it_been_fixed"))

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
                String(localized: "issues.outcome_picker.issue_number"),
                issue.number
            )
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("issues.outcome_picker.close", systemImage: "xmark") {
                    dismiss()
                }
            }
        }
        .bottomDock {
            Button("issues.outcome_picker.save") {
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
