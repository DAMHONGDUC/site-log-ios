//
//  AppLogger.swift
//  Core
//
//  Created by Duc Dam Dev on 1/10/26.
//

import os

public enum AppLogger {
    public static let subsystem = "app.dd.site.log"
    public static let startup = Logger(subsystem: subsystem, category: "Startup")
    public static let devMenu = Logger(subsystem: subsystem, category: "DevMenu")
}
