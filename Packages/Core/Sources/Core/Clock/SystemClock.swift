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
