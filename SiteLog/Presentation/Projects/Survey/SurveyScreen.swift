// P5 · Walkthrough

import DesignSystem
import Inject
import SwiftUI

struct SurveyScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    @State private var filter = "All"
    @State private var isCameraShown = false

    private let filters = ["All", "Not checked", "Has issues"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                progressHeader
                    .padding(.horizontal, DSSpacing.regular)

                HStack(spacing: DSSpacing.small) {
                    ForEach(filters, id: \.self) { item in
                        DSChip(title: item, isSelected: filter == item) {
                            filter = item
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.regular)

                ForEach(FakeData.units) { unit in
                    unitSection(unit)
                }
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
        .navigationTitle("Level 7")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Filter", systemImage: "line.3.horizontal.decrease") {}
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CaptureToolbar {
                isCameraShown = true
            } left: {
                Button("End") {
                    coordinator.push(ProjectsRoute.endSession)
                }
                .foregroundStyle(DSColor.textPrimary)
            } right: {
                Button {
                    coordinator.push(PlansRoute.viewer(planID: FakeData.plans[0].id))
                } label: {
                    ToolbarSideLabel(systemImage: "map", title: "Plan")
                }
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .fullScreenCover(isPresented: $isCameraShown) {
            CameraScreen()
        }
        .enableInjection()
    }

    private var progressHeader: some View {
        VStack(spacing: DSSpacing.small) {
            HStack {
                Text("37 of 82 rooms checked")
                Spacer()
                Text("since 8:12")
            }
            .font(DSFont.footnote)
            .foregroundStyle(DSColor.textSecondary)

            DSProgressBar(value: 37.0 / 82.0)
        }
    }

    private func unitSection(_ unit: FakeUnit) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.tiny) {
            DSSectionHeader(title: unit.name, trailing: unit.checkedText)

            ForEach(unit.rooms) { room in
                Button {
                    coordinator.push(ProjectsRoute.room(roomID: room.id))
                } label: {
                    roomRow(room)
                }
                .buttonStyle(.plain)

                DSDivider()
            }
        }
    }

    private func roomRow(_ room: FakeRoom) -> some View {
        DSListRow(title: room.name, subtitle: room.note, showsChevron: true) {
            Image(systemName: room.isChecked ? "checkmark.circle" : "circle")
                .foregroundStyle(room.isChecked ? DSColor.success : DSColor.textTertiary)
        } trailing: {
            HStack(spacing: DSSpacing.medium) {
                if room.criticalCount > 0 {
                    DSStatusMarker(kind: .critical, text: String(room.criticalCount))
                }
                if room.note != nil {
                    DSStatusMarker(kind: .major)
                }
                if room.photoCount > 0 {
                    Text(String(room.photoCount))
                        .font(DSFont.subhead)
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SurveyScreen()
    }
}
