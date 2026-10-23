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
                    DSTextField(String(localized: "projects.bulkLocations.levels"), text: $levels)
                    DSTextField(
                        String(localized: "projects.bulkLocations.unitsPerLevel"),
                        text: $units
                    )
                }

                DSTextField(
                    String(localized: "projects.bulkLocations.roomsInEveryUnit"),
                    text: $rooms,
                    isMultiline: true
                )

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("projects.bulkLocations.preview")
                            .modifier(DSTextStyle.section)
                        Spacer()
                        Text("projects.bulkLocations.120Rooms")
                            .modifier(DSTextStyle.subhead)
                            .foregroundStyle(DSColor.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                        Text("projects.bulkLocations.level77ALivingRoom")
                        Text("projects.bulkLocations.level77ABedroom1")
                        Text("projects.bulkLocations.level77ABedroom2")
                        Text("projects.bulkLocations.and117More")
                            .foregroundStyle(DSColor.textTertiary)
                    }
                    .modifier(DSTextStyle.code)
                }

                HStack(spacing: DSSpacing.spacing4) {
                    Text("projects.bulkLocations.alreadyHaveThisLayoutInAnotherProject")
                        .foregroundStyle(DSColor.textSecondary)
                    Button("projects.bulkLocations.copyItsRooms") {
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
        .navigationTitle("projects.bulkLocations.addRoomsInBulk")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            Button("projects.bulkLocations.add120Rooms") {
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
