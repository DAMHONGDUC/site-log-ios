// P6 · Add rooms in bulk

import SystemDesign
import Inject
import SwiftUI

struct BulkLocationsView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var levels = "7 to 9"
    @State private var units = "A to H"
    @State private var rooms = "Living room, Bedroom 1, Bedroom 2, Bathroom, Kitchen"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                HStack(spacing: SDSpacing.medium) {
                    SDTextField("Levels", text: $levels)
                    SDTextField("Units per level", text: $units)
                }

                SDTextField("Rooms in every unit", text: $rooms, isMultiline: true)

                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Preview")
                            .font(SDFont.section)
                        Spacer()
                        Text("120 rooms")
                            .font(SDFont.subhead)
                            .foregroundStyle(SDColor.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                        Text("Level 7 › 7A › Living room")
                        Text("Level 7 › 7A › Bedroom 1")
                        Text("Level 7 › 7A › Bedroom 2")
                        Text("and 117 more")
                            .foregroundStyle(SDColor.textTertiary)
                    }
                    .font(SDFont.code)
                }

                HStack(spacing: SDSpacing.tiny) {
                    Text("Already have this layout in another project?")
                        .foregroundStyle(SDColor.textSecondary)
                    NavigationLink("Copy its rooms") {
                        CloneTreeView()
                    }
                    .underline()
                    .foregroundStyle(SDColor.textPrimary)
                }
                .font(SDFont.footnote)
            }
            .padding(SDSpacing.regular)
        }
        .background(SDColor.canvas)
        .navigationTitle("Add rooms in bulk")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            Button("Add 120 rooms") {
                dismiss()
            }
            .buttonStyle(.sd(.primary))
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        BulkLocationsView()
    }
}
