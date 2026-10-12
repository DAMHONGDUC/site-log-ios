// M5 · Pin preview

import SystemDesign
import Inject
import SwiftUI

struct PinPreviewView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    let pin: FakePin

    @State private var isIssueShown = false

    // Fake: every pin shows the first issue
    private var issue: FakeIssue {
        FakeData.issues[0]
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: SDSpacing.medium) {
                HStack(alignment: .top, spacing: SDSpacing.medium) {
                    SitePhotoThumb(variant: issue.photoVariant, size: 64)

                    VStack(alignment: .leading) {
                        SDStatusMarker(kind: pin.severity, text: "Pin \(pin.number)")
                        Text(issue.title)
                            .font(SDFont.headline)
                        Text("\(issue.room) · \(issue.assignee) · \(issue.due)")
                            .font(SDFont.subhead)
                            .foregroundStyle(SDColor.textSecondary)
                    }
                }

                HStack(spacing: SDSpacing.small) {
                    Button("Move pin") {
                        dismiss()
                    }
                    .buttonStyle(.sd(.secondary))

                    Button("Open") {
                        isIssueShown = true
                    }
                    .buttonStyle(.sd(.primary))
                }
            }
            .padding(SDSpacing.regular)
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationDestination(isPresented: $isIssueShown) {
                IssueDetailView(issue: issue)
            }
        }
        .enableInjection()
    }
}

#Preview {
    PinPreviewView(pin: FakeData.pins[0])
}
