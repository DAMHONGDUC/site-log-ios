// P3 · Project overview

import DesignSystem
import Inject
import SwiftUI

struct ProjectDetailScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    let project: FakeProject

    enum Section: String, CaseIterable {
        case sessions = "projects.section.sessions"
        case locations = "projects.section.locations"
        case plans = "projects.section.plans"
    }

    @State private var section: Section = .sessions
    @State private var isStartSessionShown = false
    @State private var isPlanImportShown = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                header

                ProjectSectionPicker(selection: $section)

                switch section {
                case .sessions:
                    sessionsContent
                case .locations:
                    locationsContent
                case .plans:
                    PlanListScreen()
                }
            }
            .padding(.bottom, DSSpacing.spacing16)
        }
        .background(DSColor.canvas)
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("projects.projectDetail.more", systemImage: "ellipsis") {
                    Button("projects.projectDetail.newWalkthrough", systemImage: "figure.walk") {
                        isStartSessionShown = true
                    }
                    Button("projects.projectDetail.importAPlan", systemImage: "doc.badge.plus") {
                        isPlanImportShown = true
                    }
                }
            }
        }
        .bottomDock {
            dock
        }
        .sheet(isPresented: $isStartSessionShown) {
            StartSessionScreen()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isPlanImportShown) {
            PlanImportScreen()
                .presentationDetents([.medium])
        }
        .enableInjection()
    }

    private var header: some View {
        VStack(alignment: .leading) {
            Text(project.name)
                .modifier(DSTextStyle.largeTitle)
            Text(
                String.localizedStringWithFormat(
                    String(localized: "projects.projectDetail.clientAndArea"),
                    project.client,
                    project.area
                )
            )
            .modifier(DSTextStyle.subhead)
            .foregroundStyle(DSColor.textSecondary)
        }
        .padding(.horizontal, DSSpacing.spacing16)
    }

    @ViewBuilder private var dock: some View {
        switch section {
        case .sessions:
            Button("projects.projectDetail.resumeWalkthrough") {
                coordinator.push(ProjectsRoute.survey)
            }
            .buttonStyle(.sd(.primary))
        case .locations:
            Button("projects.projectDetail.addRoomsInBulk") {
                coordinator.push(ProjectsRoute.bulkLocations)
            }
            .buttonStyle(.sd(.primary))
        case .plans:
            Button {
                isPlanImportShown = true
            } label: {
                Label("projects.projectDetail.importAPlan2", systemImage: "doc.badge.plus")
            }
            .buttonStyle(.sd(.secondary))
        }
    }

    private var sessionsContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
            Text("projects.projectDetail.issueSummary")
                .modifier(DSTextStyle.body)
                .foregroundStyle(DSColor.textSecondary)
                .padding(.horizontal, DSSpacing.spacing16)

            VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                DSSectionHeader(
                    title: String(localized: "projects.projectDetail.sessions"),
                    trailing: String(FakeData.sessions.count)
                )

                ForEach(FakeData.sessions) { session in
                    Button {
                        if session.isLive {
                            coordinator.push(ProjectsRoute.survey)
                        } else {
                            coordinator.push(ProjectsRoute.endSession)
                        }
                    } label: {
                        sessionRow(session)
                    }
                    .buttonStyle(.plain)

                    DSDivider()
                }
            }
        }
    }

    private func sessionRow(_ session: FakeSession) -> some View {
        DSListRow(title: session.title, subtitle: session.summary, showsChevron: true) {
            if session.isLive {
                DSLiveDot()
            } else {
                DSColor.clear
                    .frame(width: 10, height: 10)
            }
        } trailing: {
            if session.hasPDF {
                DSFileTag(text: "PDF")
            }
        }
    }

    private var locationsContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
            ForEach(FakeData.units) { unit in
                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(title: unit.name, trailing: "\(unit.rooms.count) rooms")

                    ForEach(unit.rooms) { room in
                        Button {
                            coordinator.push(ProjectsRoute.room(roomID: room.id))
                        } label: {
                            DSListRow(title: room.name, showsChevron: true)
                        }
                        .buttonStyle(.plain)

                        DSDivider()
                    }
                }
            }

            Button {
                coordinator.push(ProjectsRoute.cloneTree)
            } label: {
                Text("projects.projectDetail.copyRoomsFromAnotherProject")
                    .modifier(DSTextStyle.subheadSemibold)
                    .underline()
                    .foregroundStyle(DSColor.textPrimary)
            }
            .padding(.horizontal, DSSpacing.spacing16)
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailScreen(project: FakeData.projects[0])
    }
}

private struct ProjectSectionPicker: View {
    @Binding var selection: ProjectDetailScreen.Section

    var body: some View {
        Picker("projects.projectDetail.section", selection: $selection) {
            ForEach(ProjectDetailScreen.Section.allCases, id: \.self) { section in
                Text(NSLocalizedString(section.rawValue, comment: "")).tag(section)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DSSpacing.spacing16)
    }
}

#Preview("Project sections") {
    ProjectSectionPicker(selection: .constant(.sessions))
}
