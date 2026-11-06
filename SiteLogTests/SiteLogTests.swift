import Core
import FactoryKit
import FactoryTesting
import Foundation
import Testing

@testable import SiteLog

struct FixedClock: AppClock {
    let now: Date
    let uptime: ContinuousClock.Instant

}

@Suite(.container)
struct CoreDITests {

    @Test func clockCanBeReplacedInTests() {
        let fixedDate = Date(timeIntervalSince1970: 0)

        Container.shared.clock.register {
            FixedClock(now: fixedDate, uptime: ContinuousClock.now)
        }

        let clock = Container.shared.clock()

        #expect(clock.now == fixedDate)
    }

}
