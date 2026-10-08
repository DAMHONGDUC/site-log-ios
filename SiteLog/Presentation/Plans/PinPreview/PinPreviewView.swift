//
//  PinPreviewView.swift
//  SiteLog
//
//  M5 · Bottom sheet after tapping a pin: issue summary, Move pin · Open.
//

import DesignSystem
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
                    .buttonStyle(.ds(.secondary))

                    Button("Open") {
                        isIssueShown = true
                    }
                    .buttonStyle(.ds(.primary))
                }
            }
            .padding(DSSpacing.regular)
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
