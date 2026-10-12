//
//  SystemClock.swift
//  Core
//
//  Created by Duc Dam Dev on 8/10/26.
//

import Foundation

public struct SystemClock: AppClock {
    public init() {}

    public var now: Date {
        return Date.now
    }

    public var uptime: ContinuousClock.Instant {
        return ContinuousClock.now
    }
}
