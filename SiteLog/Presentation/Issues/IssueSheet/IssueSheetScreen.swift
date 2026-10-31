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
                                String(localized: "issues.issue_sheet.checklist_photo_required"),
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
                            ? nil : String(localized: "issues.issue_sheet.whats_wrong"),
                        placeholder: String(localized: "issues.issue_sheet.describe_the_issue"),
                        text: $details,
                        trailingSystemImage: "mic"
                    )

                    quickPhrases

                    HStack(spacing: DSSpacing.spacing12) {
                        DSTextField(
                            String(localized: "issues.issue_sheet.assigned_to"),
                            text: $assignee
                        )
                        DSTextField(String(localized: "issues.issue_sheet.due"), text: $due)
                            .frame(width: DSSpacing.spacing112)
                    }
                }
                .padding(DSSpacing.spacing16)
            }
            .navigationTitle("issues.issue_sheet.new_issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("issues.issue_sheet.close", systemImage: "xmark") {
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
                    .accessibilityLabel("issues.issue_sheet.pin_on_plan")

                    Button(
                        checklistItem == nil
                            ? "issues.issue_sheet.save_next_photo" : "issues.issue_sheet.save_issue"
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
                Text(verbatim: "1 photo")
                    .modifier(DSTextStyle.bodyMedium)
                Text(verbatim: "10:42:18 · 7f3a…c91e")
                    .modifier(DSTextStyle.code)
                    .foregroundStyle(DSColor.textSecondary)
            }

            Spacer()

            Button("issues.issue_sheet.add") {}
                .modifier(DSTextStyle.subheadSemibold)
                .underline()
                .foregroundStyle(DSColor.textPrimary)
        }
    }

    private var severityPicker: some View {
        Picker("issues.issue_sheet.severity", selection: $severity) {
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
