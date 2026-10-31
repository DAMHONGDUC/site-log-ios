// P6 · Add rooms in bulk

import DesignSystem
import Inject
import SwiftUI

struct BulkLocationsScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator
    @Environment(\.dismiss) private var dismiss

    @State private var levels = "7 to 9"
    @State private var units = "A to H"
    @State private var rooms = "Living room, Bedroom 1, Bedroom 2, Bathroom, Kitchen"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                HStack(spacing: DSSpacing.spacing12) {
                    DSTextField(String(localized: "projects.bulk_locations.levels"), text: $levels)
                    DSTextField(
                        String(localized: "projects.bulk_locations.units_per_level"),
                        text: $units
                    )
                }

                DSTextField(
                    String(localized: "projects.bulk_locations.rooms_in_every_unit"),
                    text: $rooms,
                    isMultiline: true
                )

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("projects.bulk_locations.preview")
                            .modifier(DSTextStyle.section)
                        Spacer()
                        Text(verbatim: "120 rooms")
                            .modifier(DSTextStyle.subhead)
                            .foregroundStyle(DSColor.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                        Text(verbatim: "Level 7 › 7A › Living room")
                        Text(verbatim: "Level 7 › 7A › Bedroom 1")
                        Text(verbatim: "Level 7 › 7A › Bedroom 2")
                        Text(verbatim: "and 117 more")
                            .foregroundStyle(DSColor.textTertiary)
                    }
                    .modifier(DSTextStyle.code)
                }

                HStack(spacing: DSSpacing.spacing4) {
                    Text("projects.bulk_locations.duplicate_layout_prompt")
                        .foregroundStyle(DSColor.textSecondary)
                    Button("projects.bulk_locations.copy_its_rooms") {
                        coordinator.push(ProjectsRoute.cloneTree)
                    }
                    .underline()
                    .foregroundStyle(DSColor.textPrimary)
                }
                .modifier(DSTextStyle.footnote)
            }
            .padding(DSSpacing.spacing16)
        }
        .background(DSColor.canvas)
        .navigationTitle("projects.bulk_locations.add_rooms_in_bulk")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            Button("projects.bulk_locations.add120_rooms") {
                dismiss()
            }
            .buttonStyle(.sd(.primary))
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        BulkLocationsScreen()
    }
}
