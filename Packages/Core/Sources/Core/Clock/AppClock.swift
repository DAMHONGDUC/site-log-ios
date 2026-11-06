import Foundation

public protocol AppClock: Sendable {
    var now: Date { get }
    var uptime: ContinuousClock.Instant { get }
}
