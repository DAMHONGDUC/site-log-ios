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
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                IssuePhotoGallery(issue: issue)
                IssueSummaryView(issue: issue)
                IssueDetailRows(issue: issue)
                IssueHistoryNote()
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
                .accessibilityLabel("issues.issueDetail.share")

                Menu("issues.issueDetail.more", systemImage: "ellipsis") {
                    Button("issues.issueDetail.edit", systemImage: "pencil") {}
                    Button("issues.issueDetail.delete", systemImage: "trash", role: .destructive) {}
                }
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            HStack(spacing: DSSpacing.spacing8) {
                Button("issues.issueDetail.markUp") {
                    isMarkupShown = true
                }
                .buttonStyle(.sd(.secondary))

                Button("issues.issueDetail.reCheckNow") {
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

}

private struct IssuePhotoGallery: View {
    let issue: FakeIssue

    var body: some View {
        TabView {
            ForEach(0..<3, id: \.self) { index in
                SitePhoto(variant: issue.photoVariant + index, showsCrack: index == 0)
            }
        }
        .tabViewStyle(.page)
        .frame(height: 250)
    }
}

private struct IssueSummaryView: View {
    let issue: FakeIssue

    private var severityName: String {
        let key: String =
            switch issue.severity {
            case .critical: "issues.severity.critical"
            case .major: "issues.severity.major"
            case .minor: "issues.severity.minor"
            case .resolved: "issues.severity.resolved"
            case .waiting: "issues.severity.waiting"
            }
        return NSLocalizedString(key, comment: "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
            Text(
                String.localizedStringWithFormat(
                    String(localized: "issues.issueDetail.status"),
                    severityName,
                    issue.number
                )
            )
            .modifier(DSTextStyle.footnote)
            .foregroundStyle(DSColor.textSecondary)

            Text(issue.title)
                .modifier(DSTextStyle.title)
        }
        .padding(.horizontal, DSSpacing.spacing16)
    }
}

private struct IssueDetailRows: View {
    let issue: FakeIssue

    var body: some View {
        VStack(spacing: DSSpacing.spacing0) {
            DSListRow(title: String(localized: "issues.issueDetail.room"), value: issue.room)
            DSDivider()
            DSListRow(
                title: String(localized: "issues.issueDetail.assignedTo"),
                value: issue.assignee
            )
            DSDivider()
            DSListRow(
                title: String(localized: "issues.issueDetail.due"),
                value: issue.due.isEmpty
                    ? String(localized: "issues.issueDetail.noDate") : issue.due
            )
        }
    }
}

private struct IssueHistoryNote: View {
    var body: some View {
        Text("issues.issueDetail.openedByHanhOn12AugStillOpenOn28Aug")
            .modifier(DSTextStyle.footnote)
            .foregroundStyle(DSColor.textSecondary)
            .padding(.horizontal, DSSpacing.spacing16)
    }
}

#Preview {
    NavigationStack {
        IssueDetailScreen(issue: FakeData.issues[1])
    }
}

#Preview("Issue photos") {
    IssuePhotoGallery(issue: FakeData.issues[1])
}

#Preview("Issue summary") {
    IssueSummaryView(issue: FakeData.issues[1])
}

#Preview("Issue rows") {
    IssueDetailRows(issue: FakeData.issues[1])
}

#Preview("Issue history") {
    IssueHistoryNote()
}
