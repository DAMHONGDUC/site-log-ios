// C4 · Re-check outcome

import SystemDesign
import Inject
import SwiftUI

struct OutcomePickerView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    let issue: FakeIssue

    @State private var outcome = "Yes, close it"

    private let outcomes: [(title: String, detail: String)] = [
        ("Yes, close it", "Both photos go in the report"),
        ("Not yet", "Keep it open, add today’s photo"),
        ("It got worse", "Raise to Critical"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                HStack {
                    beforeAfterPhoto(label: "12 Aug", showsCrack: true)
                    beforeAfterPhoto(label: "Today", showsCrack: false)
                }

                VStack(alignment: .leading) {
                    Text(issue.title)
                        .font(SDFont.headline)
                    Text("\(issue.assignee) · opened 12 Aug")
                        .font(SDFont.subhead)
                        .foregroundStyle(SDColor.textSecondary)
                }
                .padding(.horizontal, SDSpacing.regular)

                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    SDSectionHeader(title: "Has it been fixed?")

                    ForEach(outcomes, id: \.title) { item in
                        Button {
                            outcome = item.title
                        } label: {
                            SDListRow(title: item.title, subtitle: item.detail) {
                                SDRadioMark(isOn: outcome == item.title)
                            }
                        }
                        .buttonStyle(.plain)

                        SDDivider()
                    }
                }
            }
        }
        .background(SDColor.canvas)
        .navigationTitle("Issue #\(issue.number)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close", systemImage: "xmark") {
                    dismiss()
                }
            }
        }
        .bottomDock {
            Button("Save") {
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
            Text(label)
                .font(SDFont.footnote)
        }
    }
}

#Preview {
    NavigationStack {
        OutcomePickerView(issue: FakeData.issues[1])
    }
}
