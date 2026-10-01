//
//  StartupStep.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 1/10/26.
//

protocol StartupStep {
    var name: String { get }
    var blocksLaunch: Bool { get }
    func run() async throws
}

enum StartupFailure: Error {
    case keychain(String)
    case database(String)
    case unexpected(step: String)
}
