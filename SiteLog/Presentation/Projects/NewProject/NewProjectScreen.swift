// P2 · New project

import DesignSystem
import Inject
import SwiftUI

struct NewProjectScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var address = ""
    @State private var client = ""
    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.spacing16) {
                    DSTextField(
                        String(localized: "projects.newProject.name"),
                        placeholder: String(localized: "projects.newProject.riversideTowerB"),
                        text: $name
                    )
                    .focused($isNameFocused)
                    DSTextField(
                        String(localized: "projects.newProject.siteAddress"),
                        placeholder: String(localized: "projects.newProject.streetDistrict"),
                        text: $address
                    )
                    DSTextField(
                        String(localized: "projects.newProject.client"),
                        placeholder: String(localized: "projects.newProject.optional"),
                        text: $client
                    )
                }
                .padding(DSSpacing.spacing16)
            }
            .navigationTitle("projects.newProject.newProject")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("projects.newProject.close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .bottomDock {
                Button("projects.newProject.createProject") {
                    dismiss()
                }
                .buttonStyle(.sd(.primary))
            }
            .onAppear {
                isNameFocused = true
            }
        }
        .enableInjection()
    }
}

#Preview {
    NewProjectScreen()
}
