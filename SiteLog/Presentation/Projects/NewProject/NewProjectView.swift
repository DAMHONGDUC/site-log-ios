// P2 · New project

import SystemDesign
import Inject
import SwiftUI

struct NewProjectView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var address = ""
    @State private var client = ""
    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SDSpacing.regular) {
                    SDTextField("Name", placeholder: "Riverside Tower B", text: $name)
                        .focused($isNameFocused)
                    SDTextField("Site address", placeholder: "Street, district", text: $address)
                    SDTextField("Client", placeholder: "Optional", text: $client)
                }
                .padding(SDSpacing.regular)
            }
            .navigationTitle("New project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .bottomDock {
                Button("Create project") {
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
    NewProjectView()
}
