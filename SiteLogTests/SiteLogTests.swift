//
//  SiteLogTests.swift
//  SiteLogTests
//
//  Created by Duc Dam Dev on 19/9/26.
//

import Core
import FactoryKit
import FactoryTesting
import Foundation
import Testing

@testable import SiteLog

struct FixedLock: AppClock {
    let now: Date
    let uptime: ContinuousClock.Instant

}

struct AppDependenciesTest {

    @Test func clockCanBeReplacedInTests() {
        let fixedDate = Date(timeIntervalSince1970: 0)

        Container.shared.clock.register {
            FixedLock(now: fixedDate, uptime: ContinuousClock.now)
        }

        let clock = Container.shared.clock()

        #expect(clock.now == fixedDate)
    }

}
