//
//  TemplatePickerView.swift
//  SiteLog
//
//  K1 · Pick a checklist: resume the one in progress, recent, all.
//

import DesignSystem
import Inject
import SwiftUI

struct TemplatePickerView: View {
    @ObserveInjection var inject

    @State private var searchText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                NavigationLink {
                    ChecklistRunView()
                } label: {
                    DSListRow(
                        title: "Finishing handover",
                        subtitle: "You stopped at item 15 of 22 this morning",
                        showsChevron: true
                    ) {
                        DSLiveDot()
                    }
                }
                .buttonStyle(.plain)

                checklistSection(title: "Used recently", items: FakeData.recentChecklists, trailing: nil)

                checklistSection(
                    title: "All checklists",
                    items: FakeData.allChecklists,
                    trailing: String(FakeData.allChecklists.count)
                )
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
        .searchable(text: $searchText)
        .navigationTitle("Checklist")
        .navigationBarTitleDisplayMode(.inline)
        .enableInjection()
    }

    private func checklistSection(title: String, items: [FakeChecklist], trailing: String?) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.tiny) {
            DSSectionHeader(title: title, trailing: trailing)

            ForEach(items) { item in
                NavigationLink {
                    ChecklistRunView(title: item.title)
                } label: {
                    DSListRow(title: item.title, subtitle: "\(item.itemCount) items", showsChevron: true)
                }
                .buttonStyle(.plain)

                DSDivider()
            }
        }
    }
}

#Preview {
    NavigationStack {
        TemplatePickerView()
    }
}
