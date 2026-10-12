// C6 · Issue detail

import SystemDesign
import Inject
import SwiftUI

struct IssueDetailView: View {
    @ObserveInjection var inject

    let issue: FakeIssue

    @State private var isMarkupShown = false
    @State private var isRecheckShown = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                TabView {
                    ForEach(0..<3, id: \.self) { index in
                        SitePhoto(variant: issue.photoVariant + index, showsCrack: index == 0)
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 250)

                VStack(alignment: .leading, spacing: SDSpacing.small) {
                    SDStatusMarker(kind: issue.severity, text: "\(severityName) · #\(issue.number)")
                    Text(issue.title)
                        .font(SDFont.title)
                }
                .padding(.horizontal, SDSpacing.regular)

                VStack(spacing: 0) {
                    SDListRow(title: "Room", value: issue.room)
                    SDDivider()
                    SDListRow(title: "Assigned to", value: issue.assignee)
                    SDDivider()
                    SDListRow(title: "Due", value: issue.due.isEmpty ? "No date" : issue.due)
                }

                Text("Opened by Hanh on 12 Aug · still open on 28 Aug")
                    .font(SDFont.footnote)
                    .foregroundStyle(SDColor.textSecondary)
                    .padding(.horizontal, SDSpacing.regular)
            }
        }
        .background(SDColor.canvas)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink {
                    StampPreviewView()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share")

                Menu("More", systemImage: "ellipsis") {
                    Button("Edit", systemImage: "pencil") {}
                    Button("Delete", systemImage: "trash", role: .destructive) {}
                }
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            HStack(spacing: SDSpacing.small) {
                Button("Mark up") {
                    isMarkupShown = true
                }
                .buttonStyle(.sd(.secondary))

                Button("Re-check now") {
                    isRecheckShown = true
                }
                .buttonStyle(.sd(.primary))
            }
        }
        .fullScreenCover(isPresented: $isMarkupShown) {
            MarkupEditorView()
        }
        .fullScreenCover(isPresented: $isRecheckShown) {
            VerificationCameraView(issue: issue)
        }
        .enableInjection()
    }

    private var severityName: String {
        switch issue.severity {
        case .critical:
            return "Critical"
        case .major:
            return "Major"
        case .minor:
            return "Minor"
        case .resolved:
            return "Resolved"
        case .waiting:
            return "Waiting"
        }
    }
}

#Preview {
    NavigationStack {
        IssueDetailView(issue: FakeData.issues[1])
    }
}
