//
//  AppDelegate.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 1/10/26.
//

import UIKit
import os

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        AppLogger.startup.info("App Launched")

        return true
    }
}
