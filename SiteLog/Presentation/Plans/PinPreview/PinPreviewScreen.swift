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
            VStack(alignment: .leading, spacing: DSSpacing.spacing12) {
                HStack(alignment: .top, spacing: DSSpacing.spacing12) {
                    SitePhotoThumb(variant: issue.photoVariant, size: 64)

                    VStack(alignment: .leading) {
                        DSStatusMarker(
                            kind: pin.severity,
                            text: String.localizedStringWithFormat(
                                String(localized: "plans.pin_preview.pin_number"),
                                pin.number
                            )
                        )
                        Text(issue.title)
                            .modifier(DSTextStyle.headline)
                        Text(
                            String.localizedStringWithFormat(
                                String(localized: "plans.pin_preview.issue_details"),
                                issue.room,
                                issue.assignee,
                                issue.due
                            )
                        )
                        .modifier(DSTextStyle.subhead)
                        .foregroundStyle(DSColor.textSecondary)
                    }
                }

                HStack(spacing: DSSpacing.spacing8) {
                    Button("plans.pin_preview.move_pin") {
                        dismiss()
                    }
                    .buttonStyle(.sd(.secondary))

                    Button("plans.pin_preview.open") {
                        // Close the sheet, then open the issue on the tab's stack
                        dismiss()
                        coordinator.push(IssuesRoute.detail(issueID: issue.id))
                    }
                    .buttonStyle(.sd(.primary))
                }
            }
            .padding(DSSpacing.spacing16)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .enableInjection()
    }
}

#Preview {
    PinPreviewScreen(pin: FakeData.pins[0])
}
