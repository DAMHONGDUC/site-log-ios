//
//  IssueListView.swift
//  SiteLog
//
//  C5 · Issues tab: Open / Closed / All, grouped by level.
//

import DesignSystem
import Inject
import SwiftUI

struct IssueListView: View {
    @ObserveInjection var inject

    enum Filter: String, CaseIterable {
        case open = "Open"
        case closed = "Closed"
        case all = "All"
    }

    @State private var filter: Filter = .open

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                Text("Riverside Tower B")
                    .font(DSFont.subhead)
                    .foregroundStyle(DSColor.textSecondary)
                    .padding(.horizontal, DSSpacing.regular)

                Picker("Filter", selection: $filter) {
                    ForEach(Filter.allCases, id: \.self) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, DSSpacing.regular)

                if visibleIssues.isEmpty {
                    DSEmptyState(
                        systemImage: "checkmark.circle",
                        title: "Nothing here",
                        message: "Issues you log on site show up in this list."
                    )
                    .frame(maxWidth: .infinity)
                } else {
                    ForEach(levels, id: \.self) { level in
                        levelSection(level)
                    }
                }
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
        .navigationTitle("Issues")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Search", systemImage: "magnifyingglass") {}
                Button("Filter", systemImage: "line.3.horizontal.decrease") {}
            }
        }
        .enableInjection()
    }

    // UI-only filtering of the fake list; the real query lives in the view model
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

        return VStack(alignment: .leading, spacing: DSSpacing.tiny) {
            DSSectionHeader(title: level, trailing: "\(issues.count) open")

            ForEach(issues) { issue in
                NavigationLink {
                    IssueDetailView(issue: issue)
                } label: {
                    IssueRow(issue: issue)
                }
                .buttonStyle(.plain)

                DSDivider()
            }
        }
    }
}

// Thumbnail · title + room · severity + due
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
                        .font(DSFont.footnote)
                        .foregroundStyle(issue.isLate ? DSColor.critical : DSColor.textSecondary)
                }
            }
        }
    }

    private var severityText: String {
        if !issue.isOpen {
            return "Resolved"
        }
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
        IssueListView()
    }
}
