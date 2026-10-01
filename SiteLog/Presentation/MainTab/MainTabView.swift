//
//  MainTabView.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 1/10/26.
//

import Inject
import SwiftUI

struct MainTabView: View {
    @ObserveInjection var inject

    var body: some View {
        TabView {
            Tab("Projects", systemImage: "folder") {
                Text("Projects")
            }
            Tab("Issues", systemImage: "exclamationmark.triangle") {
                Text("Issues")
            }
            Tab("Sync", systemImage: "arrow.triangle.2.circlepath") {
                Text("Sync")
            }
            Tab("Settings", systemImage: "gearshape") {
                Text("Settings")
            }
        }
        .enableInjection()
    }
}
