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
                        String(localized: "projects.new_project.name"),
                        placeholder: "Riverside Tower B",
                        text: $name
                    )
                    .focused($isNameFocused)
                    DSTextField(
                        String(localized: "projects.new_project.site_address"),
                        placeholder: String(localized: "projects.new_project.street_district"),
                        text: $address
                    )
                    DSTextField(
                        String(localized: "projects.new_project.client"),
                        placeholder: String(localized: "projects.new_project.optional"),
                        text: $client
                    )
                }
                .padding(DSSpacing.spacing16)
            }
            .navigationTitle("projects.new_project.new_project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("projects.new_project.close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .bottomDock {
                Button("projects.new_project.create_project") {
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
