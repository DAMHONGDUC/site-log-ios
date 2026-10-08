//
//  AppLogger.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 1/10/26.
//

import os

enum AppLogger {
    static let subsystem = "app.dd.site.log"
    static let startup = Logger(subsystem: subsystem, category: "Startup")
    static let devMenu = Logger(subsystem: subsystem, category: "DevMenu")
}
