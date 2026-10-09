//
//  AppDependencies.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 30/9/26.
//

import FactoryKit

extension Container {
    var clock: Factory<any AppClock> {
        self { SystemClock() }.singleton
    }
}
