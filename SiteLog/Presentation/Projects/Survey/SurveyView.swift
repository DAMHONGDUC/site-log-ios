// P5 · Walkthrough

import SystemDesign
import Inject
import SwiftUI

struct SurveyView: View {
    @ObserveInjection var inject

    @State private var filter = "All"
    @State private var isCameraShown = false
    @State private var isEndShown = false
    @State private var isPlanShown = false

    private let filters = ["All", "Not checked", "Has issues"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                progressHeader
                    .padding(.horizontal, SDSpacing.regular)

                HStack(spacing: SDSpacing.small) {
                    ForEach(filters, id: \.self) { item in
                        SDChip(title: item, isSelected: filter == item) {
                            filter = item
                        }
                    }
                }
                .padding(.horizontal, SDSpacing.regular)

                ForEach(FakeData.units) { unit in
                    unitSection(unit)
                }
            }
            .padding(.vertical, SDSpacing.small)
        }
        .background(SDColor.canvas)
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
                    isEndShown = true
                }
                .foregroundStyle(SDColor.textPrimary)
            } right: {
                Button {
                    isPlanShown = true
                } label: {
                    ToolbarSideLabel(systemImage: "map", title: "Plan")
                }
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $isEndShown) {
            EndSessionView()
        }
        .navigationDestination(isPresented: $isPlanShown) {
            PlanViewerView(plan: FakeData.plans[0])
        }
        .fullScreenCover(isPresented: $isCameraShown) {
            CameraView()
        }
        .enableInjection()
    }

    private var progressHeader: some View {
        VStack(spacing: SDSpacing.small) {
            HStack {
                Text("37 of 82 rooms checked")
                Spacer()
                Text("since 8:12")
            }
            .font(SDFont.footnote)
            .foregroundStyle(SDColor.textSecondary)

            SDProgressBar(value: 37.0 / 82.0)
        }
    }

    private func unitSection(_ unit: FakeUnit) -> some View {
        VStack(alignment: .leading, spacing: SDSpacing.tiny) {
            SDSectionHeader(title: unit.name, trailing: unit.checkedText)

            ForEach(unit.rooms) { room in
                NavigationLink {
                    RoomView(room: room, unitName: unit.name)
                } label: {
                    roomRow(room)
                }
                .buttonStyle(.plain)

                SDDivider()
            }
        }
    }

    private func roomRow(_ room: FakeRoom) -> some View {
        SDListRow(title: room.name, subtitle: room.note, showsChevron: true) {
            Image(systemName: room.isChecked ? "checkmark.circle" : "circle")
                .foregroundStyle(room.isChecked ? SDColor.success : SDColor.textTertiary)
        } trailing: {
            HStack(spacing: SDSpacing.medium) {
                if room.criticalCount > 0 {
                    SDStatusMarker(kind: .critical, text: String(room.criticalCount))
                }
                if room.note != nil {
                    SDStatusMarker(kind: .major)
                }
                if room.photoCount > 0 {
                    Text(String(room.photoCount))
                        .font(SDFont.subhead)
                        .foregroundStyle(SDColor.textSecondary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SurveyView()
    }
}
