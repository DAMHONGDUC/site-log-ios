// P3 · Project overview

import SystemDesign
import Inject
import SwiftUI

struct ProjectDetailView: View {
    @ObserveInjection var inject

    let project: FakeProject

    enum Section: String, CaseIterable {
        case sessions = "Sessions"
        case locations = "Locations"
        case plans = "Plans"
    }

    @State private var section: Section = .sessions
    @State private var isStartSessionShown = false
    @State private var isPlanImportShown = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                header

                Picker("Section", selection: $section) {
                    ForEach(Section.allCases, id: \.self) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, SDSpacing.regular)

                switch section {
                case .sessions:
                    sessionsContent
                case .locations:
                    locationsContent
                case .plans:
                    PlanListView()
                }
            }
            .padding(.bottom, SDSpacing.regular)
        }
        .background(SDColor.canvas)
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("More", systemImage: "ellipsis") {
                    Button("New walkthrough", systemImage: "figure.walk") {
                        isStartSessionShown = true
                    }
                    Button("Import a plan", systemImage: "doc.badge.plus") {
                        isPlanImportShown = true
                    }
                }
            }
        }
        .bottomDock {
            dock
        }
        .sheet(isPresented: $isStartSessionShown) {
            StartSessionView()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isPlanImportShown) {
            PlanImportView()
                .presentationDetents([.medium])
        }
        .enableInjection()
    }

    private var header: some View {
        VStack(alignment: .leading) {
            Text(project.name)
                .font(SDFont.largeTitle)
            Text("\(project.client) · \(project.area)")
                .font(SDFont.subhead)
                .foregroundStyle(SDColor.textSecondary)
        }
        .padding(.horizontal, SDSpacing.regular)
    }

    @ViewBuilder private var dock: some View {
        switch section {
        case .sessions:
            NavigationLink("Resume walkthrough") {
                SurveyView()
            }
            .buttonStyle(.sd(.primary))
        case .locations:
            NavigationLink("Add rooms in bulk") {
                BulkLocationsView()
            }
            .buttonStyle(.sd(.primary))
        case .plans:
            Button {
                isPlanImportShown = true
            } label: {
                Label("Import a plan", systemImage: "doc.badge.plus")
            }
            .buttonStyle(.sd(.secondary))
        }
    }

    private var sessionsContent: some View {
        VStack(alignment: .leading, spacing: SDSpacing.large) {
            Text("\(Text("14 open issues").bold()), 2 of them overdue. Last full walkthrough on 12 Aug with Hanh.")
                .font(SDFont.body)
                .foregroundStyle(SDColor.textSecondary)
                .padding(.horizontal, SDSpacing.regular)

            VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                SDSectionHeader(title: "Sessions", trailing: String(FakeData.sessions.count))

                ForEach(FakeData.sessions) { session in
                    NavigationLink {
                        if session.isLive {
                            SurveyView()
                        } else {
                            EndSessionView()
                        }
                    } label: {
                        sessionRow(session)
                    }
                    .buttonStyle(.plain)

                    SDDivider()
                }
            }
        }
    }

    private func sessionRow(_ session: FakeSession) -> some View {
        SDListRow(title: session.title, subtitle: session.summary, showsChevron: true) {
            if session.isLive {
                SDLiveDot()
            } else {
                Color.clear
                    .frame(width: 10, height: 10)
            }
        } trailing: {
            if session.hasPDF {
                SDFileTag(text: "PDF")
            }
        }
    }

    private var locationsContent: some View {
        VStack(alignment: .leading, spacing: SDSpacing.large) {
            ForEach(FakeData.units) { unit in
                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    SDSectionHeader(title: unit.name, trailing: "\(unit.rooms.count) rooms")

                    ForEach(unit.rooms) { room in
                        NavigationLink {
                            RoomView(room: room, unitName: unit.name)
                        } label: {
                            SDListRow(title: room.name, showsChevron: true)
                        }
                        .buttonStyle(.plain)

                        SDDivider()
                    }
                }
            }

            NavigationLink {
                CloneTreeView()
            } label: {
                Text("Copy rooms from another project")
                    .font(SDFont.subhead.weight(.semibold))
                    .underline()
                    .foregroundStyle(SDColor.textPrimary)
            }
            .padding(.horizontal, SDSpacing.regular)
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: FakeData.projects[0])
    }
}
