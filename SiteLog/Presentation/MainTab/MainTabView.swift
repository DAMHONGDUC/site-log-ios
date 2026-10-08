//
//  MainTabView.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 1/10/26.
//

import DesignSystem
import Inject
import SwiftUI

struct MainTabView: View {
    @ObserveInjection var inject

    var body: some View {
        TabView {
            Tab("Projects", systemImage: "folder") {
                NavigationStack {
                    ProjectListView()
                }
            }
            Tab("Issues", systemImage: "exclamationmark.triangle") {
                NavigationStack {
                    IssueListView()
                }
            }
            // Fake count; the real one comes from the issues view model
            .badge(2)
            Tab("Sync", systemImage: "arrow.triangle.2.circlepath") {
                NavigationStack {
                    UploadStatusView()
                }
            }
            Tab("Settings", systemImage: "gearshape") {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .tint(DSColor.textPrimary)
        .enableInjection()
    }
}

#Preview {
    MainTabView()
}
