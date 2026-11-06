// C5 · Issues

import DesignSystem
import Inject
import SwiftUI

struct IssueListScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    enum Filter: String, CaseIterable {
        case open = "issues.filter.open"
        case closed = "issues.filter.closed"
        case all = "issues.filter.all"
    }

    @State private var filter: Filter = .open

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                Text(verbatim: "Riverside Tower B")
                    .modifier(DSTextStyle.subhead)
                    .foregroundStyle(DSColor.textSecondary)
                    .padding(.horizontal, DSSpacing.spacing16)

                Picker("issues.issue_list.filter", selection: $filter) {
                    ForEach(Filter.allCases, id: \.self) { item in
                        Text(NSLocalizedString(item.rawValue, comment: "")).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, DSSpacing.spacing16)

                if visibleIssues.isEmpty {
                    DSEmptyState(
                        systemImage: "checkmark.circle",
                        title: String(localized: "issues.issue_list.nothing_here"),
                        message: String(
                            localized: "issues.issue_list.empty_state_message"
                        )
                    )
                    .frame(maxWidth: .infinity)
                } else {
                    ForEach(levels, id: \.self) { level in
                        levelSection(level)
                    }
                }
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("issues.issue_list.issues")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("issues.issue_list.search", systemImage: "magnifyingglass") {}
                Button("issues.issue_list.filter2", systemImage: "line.3.horizontal.decrease") {}
            }
        }
        .enableInjection()
    }

    // Temporary: the view model will filter
    private var visibleIssues: [FakeIssue] {
        switch filter {
        case .open:
            return FakeData.issues.filter { $0.isOpen }
        case .closed:
            return FakeData.issues.filter { !$0.isOpen }
        case .all:
            return FakeData.issues
        }
    }

    private var levels: [String] {
        var result: [String] = []
        for issue in visibleIssues where !result.contains(issue.level) {
            result.append(issue.level)
        }
        return result
    }

    private func levelSection(_ level: String) -> some View {
        let issues = visibleIssues.filter { $0.level == level }

        return VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
            DSSectionHeader(title: level, trailing: "\(issues.count) open")

            ForEach(issues) { issue in
                Button {
                    coordinator.push(IssuesRoute.detail(issueID: issue.id))
                } label: {
                    IssueRow(issue: issue)
                }
                .buttonStyle(.plain)

                DSDivider()
            }
        }
    }
}

struct IssueRow: View {
    let issue: FakeIssue

    var body: some View {
        DSListRow(title: issue.title, subtitle: "\(issue.room) · \(issue.assignee)") {
            SitePhotoThumb(variant: issue.photoVariant, size: 48, showsCrack: issue.number == 3)
        } trailing: {
            VStack(alignment: .trailing) {
                DSStatusMarker(kind: issue.isOpen ? issue.severity : .resolved, text: severityText)
                if !issue.due.isEmpty {
                    Text(issue.due)
                        .modifier(DSTextStyle.footnote)
                        .foregroundStyle(issue.isLate ? DSColor.critical : DSColor.textSecondary)
                }
            }
        }
    }

    private var severityText: String {
        if !issue.isOpen {
            return String(localized: "issues.severity.resolved")
        }
        switch issue.severity {
        case .critical:
            return String(localized: "issues.severity.critical")
        case .major:
            return String(localized: "issues.severity.major")
        case .minor:
            return String(localized: "issues.severity.minor")
        case .resolved:
            return String(localized: "issues.severity.resolved")
        case .waiting:
            return String(localized: "issues.severity.waiting")
        }
    }
}

#Preview {
    NavigationStack {
        IssueListScreen()
    }
}
