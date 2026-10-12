// K2 · Checklist run

import SystemDesign
import Inject
import SwiftUI

struct ChecklistRunView: View {
    @ObserveInjection var inject

    var title = "Finishing handover"

    enum Answer: String, CaseIterable {
        case pass = "Pass"
        case fail = "Fail"
        case notApplicable = "N/A"
    }

    @State private var answers: [Int: Answer] = [12: .fail, 13: .pass, 14: .notApplicable]
    @State private var failedItem: FakeChecklistItem?
    @State private var isDoneShown = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                progressHeader
                    .padding(.horizontal, SDSpacing.regular)

                VStack(spacing: 0) {
                    ForEach(FakeData.checklistItems) { item in
                        itemRow(item)
                        SDDivider()
                    }
                }
            }
            .padding(.vertical, SDSpacing.small)
        }
        .background(SDColor.canvas)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            // Demo: Finish is always enabled
            Button("Finish") {
                isDoneShown = true
            }
            .buttonStyle(.sd(.primary))

            Text("8 items still need an answer")
                .font(SDFont.footnote)
                .foregroundStyle(SDColor.textTertiary)
        }
        .navigationDestination(isPresented: $isDoneShown) {
            ChecklistDoneView()
        }
        .sheet(item: $failedItem) { item in
            IssueSheetView(checklistItem: item)
        }
        .enableInjection()
    }

    private var progressHeader: some View {
        VStack(spacing: SDSpacing.small) {
            HStack {
                Text("\(answers.count + 11) of 22 answered")
                    .foregroundStyle(SDColor.textSecondary)
                Spacer()
                Text("1 failed")
                    .foregroundStyle(SDColor.critical)
            }
            .font(SDFont.footnote)

            SDProgressBar(value: Double(answers.count + 11) / 22)
        }
    }

    private func itemRow(_ item: FakeChecklistItem) -> some View {
        VStack(alignment: .leading) {
            Text("\(item.number). \(item.text)")
                .font(SDFont.body)

            Picker("Answer", selection: answerBinding(for: item)) {
                ForEach(Answer.allCases, id: \.self) { answer in
                    Text(answer.rawValue).tag(Optional(answer))
                }
            }
            .pickerStyle(.segmented)

            if answers[item.number] == .fail {
                Text("Logged as an issue")
                    .font(SDFont.footnote)
                    .foregroundStyle(SDColor.critical)
            }
        }
        .padding()
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
        ChecklistRunView()
    }
}
