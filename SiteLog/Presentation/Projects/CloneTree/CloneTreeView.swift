import SystemDesign
import Inject
import SwiftUI

struct CloneTreeView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var selectedName: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                Text("Pick a project. Its levels, units and rooms are copied; photos and issues are not.")
                    .font(SDFont.subhead)
                    .foregroundStyle(SDColor.textSecondary)
                    .padding(.horizontal, SDSpacing.regular)
                    .padding(.bottom, SDSpacing.regular)

                SDSectionHeader(title: "Copy rooms from")

                ForEach(FakeData.projects) { project in
                    Button {
                        selectedName = project.name
                    } label: {
                        SDListRow(title: project.name, subtitle: "82 rooms · 3 levels") {
                            SDRadioMark(isOn: selectedName == project.name)
                        }
                    }
                    .buttonStyle(.plain)

                    SDDivider()
                }
            }
            .padding(.vertical, SDSpacing.small)
        }
        .background(SDColor.canvas)
        .navigationTitle("Copy rooms")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            Button("Copy 82 rooms") {
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
        CloneTreeView()
    }
}
