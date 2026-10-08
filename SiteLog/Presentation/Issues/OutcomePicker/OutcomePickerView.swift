// C4 · Re-check outcome

import DesignSystem
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
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                HStack {
                    beforeAfterPhoto(label: "12 Aug", showsCrack: true)
                    beforeAfterPhoto(label: "Today", showsCrack: false)
                }

                VStack(alignment: .leading) {
                    Text(issue.title)
                        .font(DSFont.headline)
                    Text("\(issue.assignee) · opened 12 Aug")
                        .font(DSFont.subhead)
                        .foregroundStyle(DSColor.textSecondary)
                }
                .padding(.horizontal, DSSpacing.regular)

                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: "Has it been fixed?")

                    ForEach(outcomes, id: \.title) { item in
                        Button {
                            outcome = item.title
                        } label: {
                            DSListRow(title: item.title, subtitle: item.detail) {
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
            .buttonStyle(.ds(.primary))
        }
        .enableInjection()
    }

    private func beforeAfterPhoto(label: String, showsCrack: Bool) -> some View {
        VStack {
            SitePhoto(variant: issue.photoVariant, showsCrack: showsCrack)
                .aspectRatio(3 / 4, contentMode: .fit)
            Text(label)
                .font(DSFont.footnote)
        }
    }
}

#Preview {
    NavigationStack {
        OutcomePickerView(issue: FakeData.issues[1])
    }
}
