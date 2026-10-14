// C6 · Issue detail

import DesignSystem
import Inject
import SwiftUI

struct IssueDetailScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    let issue: FakeIssue

    @State private var isMarkupShown = false
    @State private var isRecheckShown = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                TabView {
                    ForEach(0..<3, id: \.self) { index in
                        SitePhoto(variant: issue.photoVariant + index, showsCrack: index == 0)
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 250)

                VStack(alignment: .leading, spacing: DSSpacing.small) {
                    DSStatusMarker(kind: issue.severity, text: "\(severityName) · #\(issue.number)")
                    Text(issue.title)
                        .font(DSFont.title)
                }
                .padding(.horizontal, DSSpacing.regular)

                VStack(spacing: 0) {
                    DSListRow(title: "Room", value: issue.room)
                    DSDivider()
                    DSListRow(title: "Assigned to", value: issue.assignee)
                    DSDivider()
                    DSListRow(title: "Due", value: issue.due.isEmpty ? "No date" : issue.due)
                }

                Text("Opened by Hanh on 12 Aug · still open on 28 Aug")
                    .font(DSFont.footnote)
                    .foregroundStyle(DSColor.textSecondary)
                    .padding(.horizontal, DSSpacing.regular)
            }
        }
        .background(DSColor.canvas)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    coordinator.push(AnnotationRoute.stampPreview)
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
            HStack(spacing: DSSpacing.small) {
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
            MarkupEditorScreen()
        }
        .fullScreenCover(isPresented: $isRecheckShown) {
            VerificationCameraScreen(issue: issue)
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
        IssueDetailScreen(issue: FakeData.issues[1])
    }
}
