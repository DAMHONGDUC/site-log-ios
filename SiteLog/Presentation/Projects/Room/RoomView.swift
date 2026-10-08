//
//  RoomView.swift
//  SiteLog
//
//  P7 · One room: issues to re-check, today's photos, checklist,
//  capture toolbar (Issue · Capture · Checklist).
//

import DesignSystem
import Inject
import SwiftUI

struct RoomView: View {
    @ObserveInjection var inject

    let room: FakeRoom
    let unitName: String

    @State private var isCameraShown = false
    @State private var isIssueSheetShown = false
    @State private var isChecklistShown = false

    private let photoVariants = [0, 3, 2, 0, 1, 3]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                header

                recheckBanner
                    .padding(.horizontal, DSSpacing.regular)

                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: "Photos", trailing: "6 today")
                    photoGrid
                }

                NavigationLink {
                    ChecklistRunView()
                } label: {
                    DSListRow(title: "Finishing checklist", subtitle: "14 of 22 answered", value: "64%", showsChevron: true)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("More", systemImage: "ellipsis") {
                    Button("Rename room", systemImage: "pencil") {}
                    Button("Mark as checked", systemImage: "checkmark.circle") {}
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CaptureToolbar {
                isCameraShown = true
            } left: {
                Button {
                    isIssueSheetShown = true
                } label: {
                    ToolbarSideLabel(systemImage: "exclamationmark.triangle", title: "Issue")
                }
            } right: {
                Button {
                    isChecklistShown = true
                } label: {
                    ToolbarSideLabel(systemImage: "checklist", title: "Checklist")
                }
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $isChecklistShown) {
            TemplatePickerView()
        }
        .sheet(isPresented: $isIssueSheetShown) {
            IssueSheetView()
        }
        .fullScreenCover(isPresented: $isCameraShown) {
            CameraView(roomName: "\(unitName.replacingOccurrences(of: "Unit ", with: "")) · \(room.name)")
        }
        .enableInjection()
    }

    private var header: some View {
        VStack(alignment: .leading) {
            Text(room.name)
                .font(DSFont.largeTitle)
            Text("\(unitName) · Level 7")
                .font(DSFont.subhead)
                .foregroundStyle(DSColor.textSecondary)
        }
        .padding(.horizontal, DSSpacing.regular)
    }

    private var recheckBanner: some View {
        HStack(alignment: .top, spacing: DSSpacing.medium) {
            DSStatusMarker(kind: .major)

            VStack(alignment: .leading) {
                Text("2 issues to re-check from 12 Aug")
                    .font(DSFont.body.weight(.medium))
                Text("Crack by the skirting, loose socket cover")
                    .font(DSFont.subhead)
                    .foregroundStyle(DSColor.textSecondary)
            }

            Spacer()

            NavigationLink("Compare") {
                OutcomePickerView(issue: FakeData.issues[1])
            }
            .font(DSFont.subhead)
        }
    }

    private var photoGrid: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(photoVariants.indices, id: \.self) { index in
                NavigationLink {
                    IssueDetailView(issue: FakeData.issues[1])
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
        RoomView(room: FakeData.units[0].rooms[0], unitName: "Unit 7A")
    }
}
