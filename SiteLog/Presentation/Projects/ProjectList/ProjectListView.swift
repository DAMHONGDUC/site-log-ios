// P1 · Projects

import SystemDesign
import Inject
import SwiftUI

struct ProjectListView: View {
    @ObserveInjection var inject

    @State private var isNewProjectShown = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                liveSessionPanel
                    .padding(.horizontal, SDSpacing.regular)

                projectsSection

                Text("Saved on this iPhone · synced at 8:47")
                    .font(SDFont.footnote)
                    .foregroundStyle(SDColor.textTertiary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, SDSpacing.small)
        }
        .background(SDColor.canvas)
        .navigationTitle("Projects")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Search", systemImage: "magnifyingglass") {}
                Button("New project", systemImage: "plus") {
                    isNewProjectShown = true
                }
            }
        }
        .sheet(isPresented: $isNewProjectShown) {
            NewProjectView()
        }
        .enableInjection()
    }

    private var liveSessionPanel: some View {
        VStack(alignment: .leading, spacing: SDSpacing.medium) {
            HStack(spacing: SDSpacing.small) {
                SDLiveDot()
                Text("Walkthrough in progress · since 8:12")
                    .font(SDFont.footnote)
            }

            VStack(alignment: .leading) {
                Text("Riverside Tower B")
                    .font(SDFont.headline)
                Text("Level 7 · 37 of 82 rooms")
                    .font(SDFont.subhead)
                    .foregroundStyle(SDColor.textSecondary)
            }

            SDProgressBar(value: 37.0 / 82.0)

            HStack {
                Text("46 photos, 7 new issues")
                    .font(SDFont.footnote)
                    .foregroundStyle(SDColor.textSecondary)
                Spacer()
                NavigationLink("Resume") {
                    SurveyView()
                }
                .buttonStyle(.sd(.primary, small: true))
            }
        }
        .padding(SDSpacing.regular)
        .background(SDColor.fill, in: RoundedRectangle(cornerRadius: 14))
    }

    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: SDSpacing.tiny) {
            SDSectionHeader(title: "All projects")

            VStack(spacing: 0) {
                ForEach(FakeData.projects) { project in
                    NavigationLink {
                        ProjectDetailView(project: project)
                    } label: {
                        SDListRow(title: project.name, subtitle: project.summary, showsChevron: true) {
                            SitePhotoThumb(variant: project.photoVariant, size: 44)
                        }
                    }
                    .buttonStyle(.plain)

                    SDDivider()
                }

                SDListRow(title: "Archived", value: "2", showsChevron: true) {
                    Image(systemName: "archivebox")
                        .foregroundStyle(SDColor.textTertiary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProjectListView()
    }
}
