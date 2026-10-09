//
//  AppClock.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 8/10/26.
//

import Foundation

nonisolated protocol AppClock: Sendable {
    var now: Date { get }
    var uptime: ContinuousClock.Instant { get }
}
