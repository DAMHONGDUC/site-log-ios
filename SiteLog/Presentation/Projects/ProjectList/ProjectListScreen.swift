// P1 · Projects

import DesignSystem
import Inject
import SwiftUI

struct ProjectListScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    @State private var isNewProjectShown = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                liveSessionPanel
                    .padding(.horizontal, DSSpacing.spacing16)

                projectsSection

                Text(verbatim: "Saved on this iPhone · synced at 8:47")
                    .modifier(DSTextStyle.footnote)
                    .foregroundStyle(DSColor.textTertiary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("projects.project_list.projects")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("projects.project_list.search", systemImage: "magnifyingglass") {}
                Button("projects.project_list.new_project", systemImage: "plus") {
                    isNewProjectShown = true
                }
            }
        }
        .sheet(isPresented: $isNewProjectShown) {
            NewProjectScreen()
        }
        .enableInjection()
    }

    private var liveSessionPanel: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing12) {
            HStack(spacing: DSSpacing.spacing8) {
                DSLiveDot()
                Text(verbatim: "Walkthrough in progress · since 8:12")
                    .modifier(DSTextStyle.footnote)
            }

            VStack(alignment: .leading) {
                Text(verbatim: "Riverside Tower B")
                    .modifier(DSTextStyle.headline)
                Text(verbatim: "Level 7 · 37 of 82 rooms")
                    .modifier(DSTextStyle.subhead)
                    .foregroundStyle(DSColor.textSecondary)
            }

            DSProgressBar(value: 37.0 / 82.0)

            HStack {
                Text(verbatim: "46 photos, 7 new issues")
                    .modifier(DSTextStyle.footnote)
                    .foregroundStyle(DSColor.textSecondary)
                Spacer()
                Button("projects.project_list.resume") {
                    coordinator.push(ProjectsRoute.survey)
                }
                .buttonStyle(.sd(.primary, small: true))
            }
        }
        .padding(DSSpacing.spacing16)
        .background(DSColor.fill, in: RoundedRectangle(cornerRadius: DSSpacing.spacing14))
    }

    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
            DSSectionHeader(title: String(localized: "projects.project_list.all_projects"))

            VStack(spacing: DSSpacing.spacing0) {
                ForEach(FakeData.projects) { project in
                    Button {
                        coordinator.push(ProjectsRoute.detail(projectID: project.id))
                    } label: {
                        DSListRow(
                            title: project.name,
                            subtitle: project.summary,
                            showsChevron: true
                        ) {
                            SitePhotoThumb(variant: project.photoVariant, size: 44)
                        }
                    }
                    .buttonStyle(.plain)

                    DSDivider()
                }

                DSListRow(
                    title: String(localized: "projects.project_list.archived"),
                    value: "2",
                    showsChevron: true
                ) {
                    Image(systemName: "archivebox")
                        .foregroundStyle(DSColor.textTertiary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProjectListScreen()
    }
}
