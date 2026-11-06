// P7 · Room

import DesignSystem
import Inject
import SwiftUI

struct RoomScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    let room: FakeRoom
    let unitName: String

    @State private var isCameraShown = false
    @State private var isIssueSheetShown = false

    private let photoVariants = [0, 3, 2, 0, 1, 3]
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: DSSpacing.spacing2),
        count: 3
    )

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                header

                recheckBanner
                    .padding(.horizontal, DSSpacing.spacing16)

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(
                        title: String(localized: "projects.room.photos"),
                        trailing: "6 today"
                    )
                    photoGrid
                }

                Button {
                    coordinator.push(ChecklistsRoute.run(title: nil))
                } label: {
                    DSListRow(
                        title: String(localized: "projects.room.finishing_checklist"),
                        subtitle: "14 of 22 answered",
                        value: "64%",
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("projects.room.more", systemImage: "ellipsis") {
                    Button("projects.room.rename_room", systemImage: "pencil") {}
                    Button("projects.room.mark_as_checked", systemImage: "checkmark.circle") {}
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: DSSpacing.spacing0) {
            CaptureToolbar {
                isCameraShown = true
            } left: {
                Button {
                    isIssueSheetShown = true
                } label: {
                    ToolbarSideLabel(
                        systemImage: "exclamationmark.triangle",
                        title: String(localized: "projects.room.issue")
                    )
                }
            } right: {
                Button {
                    coordinator.push(ChecklistsRoute.templatePicker)
                } label: {
                    ToolbarSideLabel(
                        systemImage: "checklist",
                        title: String(localized: "projects.room.checklist")
                    )
                }
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .sheet(isPresented: $isIssueSheetShown) {
            IssueSheetScreen()
        }
        .fullScreenCover(isPresented: $isCameraShown) {
            CameraScreen(
                roomName: "\(unitName.replacingOccurrences(of: "Unit ", with: "")) · \(room.name)"
            )
        }
        .enableInjection()
    }

    private var header: some View {
        VStack(alignment: .leading) {
            Text(room.name)
                .modifier(DSTextStyle.largeTitle)
            Text(
                String.localizedStringWithFormat(
                    String(localized: "projects.room.unit_and_level"),
                    unitName
                )
            )
            .modifier(DSTextStyle.subhead)
            .foregroundStyle(DSColor.textSecondary)
        }
        .padding(.horizontal, DSSpacing.spacing16)
    }

    private var recheckBanner: some View {
        HStack(alignment: .top, spacing: DSSpacing.spacing12) {
            DSStatusMarker(kind: .major)

            VStack(alignment: .leading) {
                Text(verbatim: "2 issues to re-check from 12 Aug")
                    .modifier(DSTextStyle.bodyMedium)
                Text(verbatim: "Crack by the skirting, loose socket cover")
                    .modifier(DSTextStyle.subhead)
                    .foregroundStyle(DSColor.textSecondary)
            }

            Spacer()

            Button("projects.room.compare") {
                coordinator.push(IssuesRoute.outcome(issueID: FakeData.issues[1].id))
            }
            .modifier(DSTextStyle.subhead)
        }
    }

    private var photoGrid: some View {
        LazyVGrid(columns: columns, spacing: DSSpacing.spacing2) {
            ForEach(photoVariants.indices, id: \.self) { index in
                Button {
                    coordinator.push(IssuesRoute.detail(issueID: FakeData.issues[1].id))
                } label: {
                    SitePhoto(variant: photoVariants[index], showsCrack: index == 0)
                        .aspectRatio(1, contentMode: .fill)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RoomScreen(room: FakeData.units[0].rooms[0], unitName: "Unit 7A")
    }
}
