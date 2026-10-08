//
//  IssueSheetView.swift
//  SiteLog
//
//  C2 · New issue sheet (over the camera), also K3 when opened from a failed
//  checklist item (pass `checklistItem` to prefill).
//

import DesignSystem
import Inject
import SwiftUI

struct IssueSheetView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    // Set when the sheet comes from a failed checklist item (K3)
    var checklistItem: FakeChecklistItem?

    @State private var severity: DSStatusMarker.Kind = .major
    @State private var details = ""
    @State private var assignee = "Tuan’s masonry crew"
    @State private var due = "Fri 3 Oct"

    private let severities: [(kind: DSStatusMarker.Kind, title: String)] = [
        (.critical, "Critical"),
        (.major, "Major"),
        (.minor, "Minor"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.regular) {
                    if let checklistItem {
                        Text("From checklist item \(checklistItem.number). A photo is required.")
                            .font(DSFont.footnote)
                            .foregroundStyle(DSColor.textSecondary)
                    }

                    photoRow

                    severityPicker

                    DSTextField(
                        checklistItem == nil ? nil : "What’s wrong",
                        placeholder: "Describe the issue",
                        text: $details,
                        trailingSystemImage: "mic"
                    )

                    quickPhrases

                    HStack(spacing: DSSpacing.medium) {
                        DSTextField("Assigned to", text: $assignee)
                        DSTextField("Due", text: $due)
                            .frame(width: 112)
                    }
                }
                .padding(DSSpacing.regular)
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
                HStack(spacing: DSSpacing.small) {
                    Button {} label: {
                        Image(systemName: "mappin.and.ellipse")
                    }
                    .buttonStyle(.ds(.secondary))
                    .frame(width: 50)
                    .accessibilityLabel("Pin on plan")

                    Button(checklistItem == nil ? "Save, next photo" : "Save issue") {
                        dismiss()
                    }
                    .buttonStyle(.ds(.primary))
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
        HStack(spacing: DSSpacing.medium) {
            SitePhotoThumb(variant: 0, size: 52, showsCrack: true)

            VStack(alignment: .leading) {
                Text("1 photo")
                    .font(DSFont.body.weight(.medium))
                Text("10:42:18 · 7f3a…c91e")
                    .font(DSFont.code)
                    .foregroundStyle(DSColor.textSecondary)
            }

            Spacer()

            Button("Add") {}
                .font(DSFont.subhead.weight(.semibold))
                .underline()
                .foregroundStyle(DSColor.textPrimary)
        }
    }

    // Segmented control with the severity shapes
    private var severityPicker: some View {
        Picker("Severity", selection: $severity) {
            ForEach(severities, id: \.title) { item in
                Text(item.title).tag(item.kind)
            }
        }
        .pickerStyle(.segmented)
    }

    private var quickPhrases: some View {
        HStack(spacing: DSSpacing.small) {
            ForEach(FakeData.quickPhrases, id: \.self) { phrase in
                DSChip(title: phrase, isSelected: false) {
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
