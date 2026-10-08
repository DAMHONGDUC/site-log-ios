// P3 · Project overview

import DesignSystem
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
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                header

                Picker("Section", selection: $section) {
                    ForEach(Section.allCases, id: \.self) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, DSSpacing.regular)

                switch section {
                case .sessions:
                    sessionsContent
                case .locations:
                    locationsContent
                case .plans:
                    PlanListView()
                }
            }
            .padding(.bottom, DSSpacing.regular)
        }
        .background(DSColor.canvas)
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
                .font(DSFont.largeTitle)
            Text("\(project.client) · \(project.area)")
                .font(DSFont.subhead)
                .foregroundStyle(DSColor.textSecondary)
        }
        .padding(.horizontal, DSSpacing.regular)
    }

    @ViewBuilder private var dock: some View {
        switch section {
        case .sessions:
            NavigationLink("Resume walkthrough") {
                SurveyView()
            }
            .buttonStyle(.ds(.primary))
        case .locations:
            NavigationLink("Add rooms in bulk") {
                BulkLocationsView()
            }
            .buttonStyle(.ds(.primary))
        case .plans:
            Button {
                isPlanImportShown = true
            } label: {
                Label("Import a plan", systemImage: "doc.badge.plus")
            }
            .buttonStyle(.ds(.secondary))
        }
    }

    private var sessionsContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.large) {
            Text("\(Text("14 open issues").bold()), 2 of them overdue. Last full walkthrough on 12 Aug with Hanh.")
                .font(DSFont.body)
                .foregroundStyle(DSColor.textSecondary)
                .padding(.horizontal, DSSpacing.regular)

            VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                DSSectionHeader(title: "Sessions", trailing: String(FakeData.sessions.count))

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
                Color.clear
                    .frame(width: 10, height: 10)
            }
        } trailing: {
            if session.hasPDF {
                DSFileTag(text: "PDF")
            }
        }
    }

    private var locationsContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.large) {
            ForEach(FakeData.units) { unit in
                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: unit.name, trailing: "\(unit.rooms.count) rooms")

                    ForEach(unit.rooms) { room in
                        NavigationLink {
                            RoomView(room: room, unitName: unit.name)
                        } label: {
                            DSListRow(title: room.name, showsChevron: true)
                        }
                        .buttonStyle(.plain)

                        DSDivider()
                    }
                }
            }

            NavigationLink {
                CloneTreeView()
            } label: {
                Text("Copy rooms from another project")
                    .font(DSFont.subhead.weight(.semibold))
                    .underline()
                    .foregroundStyle(DSColor.textPrimary)
            }
            .padding(.horizontal, DSSpacing.regular)
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: FakeData.projects[0])
    }
}
