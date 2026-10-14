// M5 · Pin preview

import DesignSystem
import Inject
import SwiftUI

struct PinPreviewScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator
    @Environment(\.dismiss) private var dismiss

    let pin: FakePin

    // Fake: every pin shows the first issue
    private var issue: FakeIssue {
        FakeData.issues[0]
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: DSSpacing.medium) {
                HStack(alignment: .top, spacing: DSSpacing.medium) {
                    SitePhotoThumb(variant: issue.photoVariant, size: 64)

                    VStack(alignment: .leading) {
                        DSStatusMarker(kind: pin.severity, text: "Pin \(pin.number)")
                        Text(issue.title)
                            .font(DSFont.headline)
                        Text("\(issue.room) · \(issue.assignee) · \(issue.due)")
                            .font(DSFont.subhead)
                            .foregroundStyle(DSColor.textSecondary)
                    }
                }

                HStack(spacing: DSSpacing.small) {
                    Button("Move pin") {
                        dismiss()
                    }
                    .buttonStyle(.sd(.secondary))

                    Button("Open") {
                        // Close the sheet, then open the issue on the tab's stack
                        dismiss()
                        coordinator.push(IssuesRoute.detail(issueID: issue.id))
                    }
                    .buttonStyle(.sd(.primary))
                }
            }
            .padding(DSSpacing.regular)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .enableInjection()
    }
}

#Preview {
    PinPreviewScreen(pin: FakeData.pins[0])
}
