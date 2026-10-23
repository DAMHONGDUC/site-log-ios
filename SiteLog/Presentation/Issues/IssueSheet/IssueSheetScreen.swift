// C2 · New issue

import DesignSystem
import Inject
import SwiftUI

struct IssueSheetScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    // Set when opened from a failed checklist item
    var checklistItem: FakeChecklistItem?

    @State private var severity: DSStatusMarker.Kind = .major
    @State private var details = ""
    @State private var assignee = "Tuan’s masonry crew"
    @State private var due = "Fri 3 Oct"

    private let severities: [(kind: DSStatusMarker.Kind, titleKey: String)] = [
        (.critical, "issues.severity.critical"),
        (.major, "issues.severity.major"),
        (.minor, "issues.severity.minor"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.spacing16) {
                    if let checklistItem {
                        Text(
                            String.localizedStringWithFormat(
                                String(localized: "issues.issueSheet.checklistPhotoRequired"),
                                checklistItem.number
                            )
                        )
                        .modifier(DSTextStyle.footnote)
                        .foregroundStyle(DSColor.textSecondary)
                    }

                    photoRow

                    severityPicker

                    DSTextField(
                        checklistItem == nil
                            ? nil : String(localized: "issues.issueSheet.whatsWrong"),
                        placeholder: String(localized: "issues.issueSheet.describeTheIssue"),
                        text: $details,
                        trailingSystemImage: "mic"
                    )

                    quickPhrases

                    HStack(spacing: DSSpacing.spacing12) {
                        DSTextField(
                            String(localized: "issues.issueSheet.assignedTo"),
                            text: $assignee
                        )
                        DSTextField(String(localized: "issues.issueSheet.due"), text: $due)
                            .frame(width: DSSpacing.spacing112)
                    }
                }
                .padding(DSSpacing.spacing16)
            }
            .navigationTitle("issues.issueSheet.newIssue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("issues.issueSheet.close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .bottomDock {
                HStack(spacing: DSSpacing.spacing8) {
                    Button {
                    } label: {
                        Image(systemName: "mappin.and.ellipse")
                    }
                    .buttonStyle(.sd(.secondary))
                    .frame(width: DSSpacing.spacing50)
                    .accessibilityLabel("issues.issueSheet.pinOnPlan")

                    Button(
                        checklistItem == nil
                            ? "issues.issueSheet.saveNextPhoto" : "issues.issueSheet.saveIssue"
                    ) {
                        dismiss()
                    }
                    .buttonStyle(.sd(.primary))
                }
            }
            .task {
                if let checklistItem, details.isEmpty {
                    details = checklistItem.text
                }
            }
        }
        .enableInjection()
    }

    private var photoRow: some View {
        HStack(spacing: DSSpacing.spacing12) {
            SitePhotoThumb(variant: 0, size: 52, showsCrack: true)

            VStack(alignment: .leading) {
                Text("issues.issueSheet.1Photo")
                    .modifier(DSTextStyle.bodyMedium)
                Text("issues.issueSheet.1042187F3AC91E")
                    .modifier(DSTextStyle.code)
                    .foregroundStyle(DSColor.textSecondary)
            }

            Spacer()

            Button("issues.issueSheet.add") {}
                .modifier(DSTextStyle.subheadSemibold)
                .underline()
                .foregroundStyle(DSColor.textPrimary)
        }
    }

    private var severityPicker: some View {
        Picker("issues.issueSheet.severity", selection: $severity) {
            ForEach(severities, id: \.titleKey) { item in
                Text(NSLocalizedString(item.titleKey, comment: "")).tag(item.kind)
            }
        }
        .pickerStyle(.segmented)
    }

    private var quickPhrases: some View {
        HStack(spacing: DSSpacing.spacing8) {
            ForEach(FakeData.quickPhrases, id: \.self) { phrase in
                DSChip(title: phrase, isSelected: false) {
                    details = phrase
                }
            }
        }
    }
}

#Preview("Camera") {
    IssueSheetScreen()
}

#Preview("From checklist") {
    IssueSheetScreen(checklistItem: FakeData.checklistItems[0])
}
