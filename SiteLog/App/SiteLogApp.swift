//
//  SiteLogApp.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 30/9/26.
//

import SwiftUI

@main
struct SiteLogApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
