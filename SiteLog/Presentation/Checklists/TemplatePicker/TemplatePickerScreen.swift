// K1 · Pick a checklist

import DesignSystem
import Inject
import SwiftUI

struct TemplatePickerScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    @State private var searchText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                Button {
                    coordinator.push(ChecklistsRoute.run(title: nil))
                } label: {
                    DSListRow(
                        title: String(localized: "checklists.template_picker.finishing_handover"),
                        subtitle: String(
                            localized: "checklists.template_picker.progress_reminder"
                        ),
                        showsChevron: true
                    ) {
                        DSLiveDot()
                    }
                }
                .buttonStyle(.plain)

                checklistSection(
                    title: String(localized: "checklists.template_picker.used_recently"),
                    items: FakeData.recentChecklists,
                    trailing: nil
                )

                checklistSection(
                    title: String(localized: "checklists.template_picker.all_checklists"),
                    items: FakeData.allChecklists,
                    trailing: String(FakeData.allChecklists.count)
                )
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .searchable(text: $searchText)
        .navigationTitle("checklists.template_picker.checklist")
        .navigationBarTitleDisplayMode(.inline)
        .enableInjection()
    }

    private func checklistSection(
        title: String,
        items: [FakeChecklist],
        trailing: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
            DSSectionHeader(title: title, trailing: trailing)

            ForEach(items) { item in
                Button {
                    coordinator.push(ChecklistsRoute.run(title: item.title))
                } label: {
                    DSListRow(
                        title: item.title,
                        subtitle: String.localizedStringWithFormat(
                            String(localized: "checklists.template_picker.item_count"),
                            item.itemCount
                        ),
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)

                DSDivider()
            }
        }
    }
}

#Preview {
    NavigationStack {
        TemplatePickerScreen()
    }
}
