// P6 · Add rooms in bulk

import DesignSystem
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
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                HStack(spacing: DSSpacing.medium) {
                    DSTextField("Levels", text: $levels)
                    DSTextField("Units per level", text: $units)
                }

                DSTextField("Rooms in every unit", text: $rooms, isMultiline: true)

                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Preview")
                            .font(DSFont.section)
                        Spacer()
                        Text("120 rooms")
                            .font(DSFont.subhead)
                            .foregroundStyle(DSColor.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                        Text("Level 7 › 7A › Living room")
                        Text("Level 7 › 7A › Bedroom 1")
                        Text("Level 7 › 7A › Bedroom 2")
                        Text("and 117 more")
                            .foregroundStyle(DSColor.textTertiary)
                    }
                    .font(DSFont.code)
                }

                HStack(spacing: DSSpacing.tiny) {
                    Text("Already have this layout in another project?")
                        .foregroundStyle(DSColor.textSecondary)
                    NavigationLink("Copy its rooms") {
                        CloneTreeView()
                    }
                    .underline()
                    .foregroundStyle(DSColor.textPrimary)
                }
                .font(DSFont.footnote)
            }
            .padding(DSSpacing.regular)
        }
        .background(DSColor.canvas)
        .navigationTitle("Add rooms in bulk")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            Button("Add 120 rooms") {
                dismiss()
            }
            .buttonStyle(.ds(.primary))
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        BulkLocationsView()
    }
}
