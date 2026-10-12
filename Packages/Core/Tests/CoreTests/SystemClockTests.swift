import Foundation
import Testing

@testable import Core

struct SystemClockTests {
    @Test func uptimeMovesForward() async throws {
        let systemClock = SystemClock()
        let first = systemClock.uptime

        try await Task.sleep(for: .milliseconds(10))

        let second = systemClock.uptime

        #expect(first < second)
    }
}
