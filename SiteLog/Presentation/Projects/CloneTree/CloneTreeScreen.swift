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
                    "projects.cloneTree.pickAProjectItsLevelsUnitsAndRoomsAreCopiedPhotosAndIssuesAreNot"
                )
                .modifier(DSTextStyle.subhead)
                .foregroundStyle(DSColor.textSecondary)
                .padding(.horizontal, DSSpacing.spacing16)
                .padding(.bottom, DSSpacing.spacing16)

                DSSectionHeader(title: String(localized: "projects.cloneTree.copyRoomsFrom"))

                ForEach(FakeData.projects) { project in
                    Button {
                        selectedName = project.name
                    } label: {
                        DSListRow(
                            title: project.name,
                            subtitle: String(localized: "projects.cloneTree.82Rooms3Levels")
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
        .navigationTitle("projects.cloneTree.copyRooms")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            Button("projects.cloneTree.copy82Rooms") {
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
