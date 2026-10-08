//
//  ProjectListView.swift
//  SiteLog
//
//  P1 · Projects tab: the live walkthrough on top, then every project.
//

import DesignSystem
import Inject
import SwiftUI

struct ProjectListView: View {
    @ObserveInjection var inject

    @State private var isNewProjectShown = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                liveSessionPanel
                    .padding(.horizontal, DSSpacing.regular)

                projectsSection

                Text("Saved on this iPhone · synced at 8:47")
                    .font(DSFont.footnote)
                    .foregroundStyle(DSColor.textTertiary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
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

    // Grey panel for the walkthrough in progress
    private var liveSessionPanel: some View {
        VStack(alignment: .leading, spacing: DSSpacing.medium) {
            HStack(spacing: DSSpacing.small) {
                DSLiveDot()
                Text("Walkthrough in progress · since 8:12")
                    .font(DSFont.footnote)
            }

            VStack(alignment: .leading) {
                Text("Riverside Tower B")
                    .font(DSFont.headline)
                Text("Level 7 · 37 of 82 rooms")
                    .font(DSFont.subhead)
                    .foregroundStyle(DSColor.textSecondary)
            }

            DSProgressBar(value: 37.0 / 82.0)

            HStack {
                Text("46 photos, 7 new issues")
                    .font(DSFont.footnote)
                    .foregroundStyle(DSColor.textSecondary)
                Spacer()
                NavigationLink("Resume") {
                    SurveyView()
                }
                .buttonStyle(.ds(.primary, small: true))
            }
        }
        .padding(DSSpacing.regular)
        .background(DSColor.fill, in: RoundedRectangle(cornerRadius: 14))
    }

    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.tiny) {
            DSSectionHeader(title: "All projects")

            VStack(spacing: 0) {
                ForEach(FakeData.projects) { project in
                    NavigationLink {
                        ProjectDetailView(project: project)
                    } label: {
                        DSListRow(title: project.name, subtitle: project.summary, showsChevron: true) {
                            SitePhotoThumb(variant: project.photoVariant, size: 44)
                        }
                    }
                    .buttonStyle(.plain)

                    DSDivider()
                }

                DSListRow(title: "Archived", value: "2", showsChevron: true) {
                    Image(systemName: "archivebox")
                        .foregroundStyle(DSColor.textTertiary)
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
