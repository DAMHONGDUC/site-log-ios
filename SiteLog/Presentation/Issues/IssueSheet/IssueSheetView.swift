// C2 · New issue

import SystemDesign
import Inject
import SwiftUI

struct IssueSheetView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    // Set when opened from a failed checklist item
    var checklistItem: FakeChecklistItem?

    @State private var severity: SDStatusMarker.Kind = .major
    @State private var details = ""
    @State private var assignee = "Tuan’s masonry crew"
    @State private var due = "Fri 3 Oct"

    private let severities: [(kind: SDStatusMarker.Kind, title: String)] = [
        (.critical, "Critical"),
        (.major, "Major"),
        (.minor, "Minor"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SDSpacing.regular) {
                    if let checklistItem {
                        Text("From checklist item \(checklistItem.number). A photo is required.")
                            .font(SDFont.footnote)
                            .foregroundStyle(SDColor.textSecondary)
                    }

                    photoRow

                    severityPicker

                    SDTextField(
                        checklistItem == nil ? nil : "What’s wrong",
                        placeholder: "Describe the issue",
                        text: $details,
                        trailingSystemImage: "mic"
                    )

                    quickPhrases

                    HStack(spacing: SDSpacing.medium) {
                        SDTextField("Assigned to", text: $assignee)
                        SDTextField("Due", text: $due)
                            .frame(width: 112)
                    }
                }
                .padding(SDSpacing.regular)
            }
            .navigationTitle("New issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .bottomDock {
                HStack(spacing: SDSpacing.small) {
                    Button {} label: {
                        Image(systemName: "mappin.and.ellipse")
                    }
                    .buttonStyle(.sd(.secondary))
                    .frame(width: 50)
                    .accessibilityLabel("Pin on plan")

                    Button(checklistItem == nil ? "Save, next photo" : "Save issue") {
                        dismiss()
                    }
                    .buttonStyle(.sd(.primary))
                }
            }
            .onAppear {
                if let checklistItem, details.isEmpty {
                    details = checklistItem.text
                }
            }
        }
        .enableInjection()
    }

    private var photoRow: some View {
        HStack(spacing: SDSpacing.medium) {
            SitePhotoThumb(variant: 0, size: 52, showsCrack: true)

            VStack(alignment: .leading) {
                Text("1 photo")
                    .font(SDFont.body.weight(.medium))
                Text("10:42:18 · 7f3a…c91e")
                    .font(SDFont.code)
                    .foregroundStyle(SDColor.textSecondary)
            }

            Spacer()

            Button("Add") {}
                .font(SDFont.subhead.weight(.semibold))
                .underline()
                .foregroundStyle(SDColor.textPrimary)
        }
    }

    private var severityPicker: some View {
        Picker("Severity", selection: $severity) {
            ForEach(severities, id: \.title) { item in
                Text(item.title).tag(item.kind)
            }
        }
        .pickerStyle(.segmented)
    }

    private var quickPhrases: some View {
        HStack(spacing: SDSpacing.small) {
            ForEach(FakeData.quickPhrases, id: \.self) { phrase in
                SDChip(title: phrase, isSelected: false) {
                    details = phrase
                }
            }
        }
    }
}

#Preview("Camera") {
    IssueSheetView()
}

#Preview("From checklist") {
    IssueSheetView(checklistItem: FakeData.checklistItems[0])
}
