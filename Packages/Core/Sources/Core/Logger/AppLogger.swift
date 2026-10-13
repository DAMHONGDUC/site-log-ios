import os

public enum AppLogger {
    public static let subsystem = "app.dd.site.log"
    public static let startup = Logger(subsystem: subsystem, category: "Startup")
    public static let devMenu = Logger(subsystem: subsystem, category: "DevMenu")
    public static let access = Logger(subsystem: subsystem, category: "Access")
}
