//
//  SystemClock.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 8/10/26.
//

import Foundation

struct SystemClock: AppClock {
    var now: Date {
        return Date.now
    }

    var uptime: ContinuousClock.Instant {
        return ContinuousClock.now
    }
}
