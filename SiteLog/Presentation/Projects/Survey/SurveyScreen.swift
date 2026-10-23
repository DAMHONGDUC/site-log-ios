// P5 · Walkthrough

import DesignSystem
import Inject
import SwiftUI

struct SurveyScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    @State private var filter = "projects.survey.filter.all"
    @State private var isCameraShown = false

    private let filters = [
        "projects.survey.filter.all", "projects.survey.filter.notChecked",
        "projects.survey.filter.hasIssues",
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                progressHeader
                    .padding(.horizontal, DSSpacing.spacing16)

                HStack(spacing: DSSpacing.spacing8) {
                    ForEach(filters, id: \.self) { item in
                        DSChip(
                            title: NSLocalizedString(item, comment: ""),
                            isSelected: filter == item
                        ) {
                            filter = item
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.spacing16)

                ForEach(FakeData.units) { unit in
                    unitSection(unit)
                }
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("projects.survey.level7")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("projects.survey.filter", systemImage: "line.3.horizontal.decrease") {}
            }
        }
        .safeAreaInset(edge: .bottom, spacing: DSSpacing.spacing0) {
            CaptureToolbar {
                isCameraShown = true
            } left: {
                Button("projects.survey.end") {
                    coordinator.push(ProjectsRoute.endSession)
                }
                .foregroundStyle(DSColor.textPrimary)
            } right: {
                Button {
                    coordinator.push(PlansRoute.viewer(planID: FakeData.plans[0].id))
                } label: {
                    ToolbarSideLabel(
                        systemImage: "map",
                        title: String(localized: "projects.survey.plan")
                    )
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
        VStack(spacing: DSSpacing.spacing8) {
            HStack {
                Text("projects.survey.37Of82RoomsChecked")
                Spacer()
                Text("projects.survey.since812")
            }
            .modifier(DSTextStyle.footnote)
            .foregroundStyle(DSColor.textSecondary)

            DSProgressBar(value: 37.0 / 82.0)
        }
    }

    private func unitSection(_ unit: FakeUnit) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
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
            HStack(spacing: DSSpacing.spacing12) {
                if room.criticalCount > 0 {
                    DSStatusMarker(kind: .critical, text: String(room.criticalCount))
                }
                if room.note != nil {
                    DSStatusMarker(kind: .major)
                }
                if room.photoCount > 0 {
                    Text(String(room.photoCount))
                        .modifier(DSTextStyle.subhead)
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
