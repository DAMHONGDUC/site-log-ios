import DesignSystem
import Inject
import SwiftUI

struct MainTabView: View {
    @ObserveInjection var inject

    var body: some View {
        TabView {
            Tab("maintab.mainTabView.projects", systemImage: "folder") {
                CoordinatedStack {
                    ProjectListScreen()
                }
            }
            Tab("maintab.mainTabView.issues", systemImage: "exclamationmark.triangle") {
                CoordinatedStack {
                    IssueListScreen()
                }
            }
            // Fake count until the issues view model
            .badge(2)
            Tab("maintab.mainTabView.sync", systemImage: "arrow.triangle.2.circlepath") {
                CoordinatedStack {
                    UploadStatusScreen()
                }
            }
            Tab("maintab.mainTabView.settings", systemImage: "gearshape") {
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
