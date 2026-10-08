import DesignSystem
import Inject
import SwiftUI

struct CloneTreeView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var selectedName: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                Text("Pick a project. Its levels, units and rooms are copied; photos and issues are not.")
                    .font(DSFont.subhead)
                    .foregroundStyle(DSColor.textSecondary)
                    .padding(.horizontal, DSSpacing.regular)
                    .padding(.bottom, DSSpacing.regular)

                DSSectionHeader(title: "Copy rooms from")

                ForEach(FakeData.projects) { project in
                    Button {
                        selectedName = project.name
                    } label: {
                        DSListRow(title: project.name, subtitle: "82 rooms · 3 levels") {
                            DSRadioMark(isOn: selectedName == project.name)
                        }
                    }
                    .buttonStyle(.plain)

                    DSDivider()
                }
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
        .navigationTitle("Copy rooms")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            Button("Copy 82 rooms") {
                dismiss()
            }
            .buttonStyle(.ds(.primary))
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
