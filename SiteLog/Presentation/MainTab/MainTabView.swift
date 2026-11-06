import DesignSystem
import Inject
import SwiftUI

struct MainTabView: View {
    @ObserveInjection var inject

    var body: some View {
        TabView {
            Tab("maintab.main_tab_view.projects", systemImage: "folder") {
                CoordinatedStack {
                    ProjectListScreen()
                }
            }
            Tab("maintab.main_tab_view.issues", systemImage: "exclamationmark.triangle") {
                CoordinatedStack {
                    IssueListScreen()
                }
            }
            // Fake count until the issues view model
            .badge(2)
            Tab("maintab.main_tab_view.sync", systemImage: "arrow.triangle.2.circlepath") {
                CoordinatedStack {
                    UploadStatusScreen()
                }
            }
            Tab("maintab.main_tab_view.settings", systemImage: "gearshape") {
                CoordinatedStack {
                    SettingsScreen()
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
