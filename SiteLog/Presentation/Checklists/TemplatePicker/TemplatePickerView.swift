// K1 · Pick a checklist

import SystemDesign
import Inject
import SwiftUI

struct TemplatePickerView: View {
    @ObserveInjection var inject

    @State private var searchText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                NavigationLink {
                    ChecklistRunView()
                } label: {
                    SDListRow(
                        title: "Finishing handover",
                        subtitle: "You stopped at item 15 of 22 this morning",
                        showsChevron: true
                    ) {
                        SDLiveDot()
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
            .padding(.vertical, SDSpacing.small)
        }
        .background(SDColor.canvas)
        .searchable(text: $searchText)
        .navigationTitle("Checklist")
        .navigationBarTitleDisplayMode(.inline)
        .enableInjection()
    }

    private func checklistSection(title: String, items: [FakeChecklist], trailing: String?) -> some View {
        VStack(alignment: .leading, spacing: SDSpacing.tiny) {
            SDSectionHeader(title: title, trailing: trailing)

            ForEach(items) { item in
                NavigationLink {
                    ChecklistRunView(title: item.title)
                } label: {
                    SDListRow(title: item.title, subtitle: "\(item.itemCount) items", showsChevron: true)
                }
                .buttonStyle(.plain)

                SDDivider()
            }
        }
    }
}

#Preview {
    NavigationStack {
        TemplatePickerView()
    }
}
