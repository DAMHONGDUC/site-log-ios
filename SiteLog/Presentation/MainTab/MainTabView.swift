import DesignSystem
import Inject
import SwiftUI

struct MainTabView: View {
    @ObserveInjection var inject

    var body: some View {
        TabView {
            Tab("Projects", systemImage: "folder") {
                CoordinatedStack {
                    ProjectListScreen()
                }
            }
            Tab("Issues", systemImage: "exclamationmark.triangle") {
                CoordinatedStack {
                    IssueListScreen()
                }
            }
            // Fake count until the issues view model
            .badge(2)
            Tab("Sync", systemImage: "arrow.triangle.2.circlepath") {
                CoordinatedStack {
                    UploadStatusScreen()
                }
            }
            Tab("Settings", systemImage: "gearshape") {
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
