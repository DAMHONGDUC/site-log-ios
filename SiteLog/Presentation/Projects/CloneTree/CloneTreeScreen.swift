import DesignSystem
import Inject
import SwiftUI

struct CloneTreeScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var selectedName: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                Text(
                    "projects.clone_tree.copy_details"
                )
                .modifier(DSTextStyle.subhead)
                .foregroundStyle(DSColor.textSecondary)
                .padding(.horizontal, DSSpacing.spacing16)
                .padding(.bottom, DSSpacing.spacing16)

                DSSectionHeader(title: String(localized: "projects.clone_tree.copy_rooms_from"))

                ForEach(FakeData.projects) { project in
                    Button {
                        selectedName = project.name
                    } label: {
                        DSListRow(
                            title: project.name,
                            subtitle: "82 rooms · 3 levels"
                        ) {
                            DSRadioMark(isOn: selectedName == project.name)
                        }
                    }
                    .buttonStyle(.plain)

                    DSDivider()
                }
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("projects.clone_tree.copy_rooms")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            Button("projects.clone_tree.copy82_rooms") {
                dismiss()
            }
            .buttonStyle(.sd(.primary))
            .disabled(selectedName == nil)
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        CloneTreeScreen()
    }
}
