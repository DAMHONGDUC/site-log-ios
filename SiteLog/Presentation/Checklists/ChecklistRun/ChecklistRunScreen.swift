// K2 · Checklist run

import DesignSystem
import Inject
import SwiftUI

struct ChecklistRunScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    var title = String(localized: "checklists.checklist_run.finishing_handover")

    enum Answer: String, CaseIterable {
        case pass = "checklists.answer.pass"
        case fail = "checklists.answer.fail"
        case notApplicable = "checklists.answer.not_applicable"
    }

    @State private var answers: [Int: Answer] = [12: .fail, 13: .pass, 14: .notApplicable]
    @State private var failedItem: FakeChecklistItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                progressHeader
                    .padding(.horizontal, DSSpacing.spacing16)

                VStack(spacing: DSSpacing.spacing0) {
                    ForEach(FakeData.checklistItems) { item in
                        itemRow(item)
                        DSDivider()
                    }
                }
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            // Demo: Finish is always enabled
            Button("checklists.checklist_run.finish") {
                coordinator.push(ChecklistsRoute.done)
            }
            .buttonStyle(.sd(.primary))

            Text("checklists.checklist_run.remaining_items_note")
                .modifier(DSTextStyle.footnote)
                .foregroundStyle(DSColor.textTertiary)
        }
        .sheet(item: $failedItem) { item in
            IssueSheetScreen(checklistItem: item)
        }
        .enableInjection()
    }

    private var progressHeader: some View {
        VStack(spacing: DSSpacing.spacing8) {
            HStack {
                Text(
                    String.localizedStringWithFormat(
                        String(localized: "checklists.checklist_run.answers_progress"),
                        answers.count + 11,
                        22
                    )
                )
                .foregroundStyle(DSColor.textSecondary)
                Spacer()
                Text(verbatim: "1 failed")
                    .foregroundStyle(DSColor.critical)
            }
            .modifier(DSTextStyle.footnote)

            DSProgressBar(value: Double(answers.count + 11) / 22)
        }
    }

    private func itemRow(_ item: FakeChecklistItem) -> some View {
        VStack(alignment: .leading) {
            Text(
                String.localizedStringWithFormat(
                    String(localized: "checklists.checklist_run.item_number_and_text"),
                    item.number,
                    item.text
                )
            )
            .modifier(DSTextStyle.body)

            Picker("checklists.checklist_run.answer", selection: answerBinding(for: item)) {
                ForEach(Answer.allCases, id: \.self) { answer in
                    Text(NSLocalizedString(answer.rawValue, comment: "")).tag(Optional(answer))
                }
            }
            .pickerStyle(.segmented)

            if answers[item.number] == .fail {
                Text("checklists.checklist_run.logged_as_an_issue")
                    .modifier(DSTextStyle.footnote)
                    .foregroundStyle(DSColor.critical)
            }
        }
        .padding(DSSpacing.spacing16)
    }

    // Picking Fail also opens the issue sheet (K3)
    private func answerBinding(for item: FakeChecklistItem) -> Binding<Answer?> {
        Binding(
            get: { answers[item.number] },
            set: { newValue in
                answers[item.number] = newValue
                if newValue == .fail {
                    failedItem = item
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        ChecklistRunScreen()
    }
}
