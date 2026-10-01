//
//  StartupSequence.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 1/10/26.
//

import os

struct StartupSequence {
    let steps: [StartupStep]

    func run() async -> StartupFailure? {
        for step in steps {
            do {
                try await step.run()
                AppLogger.startup.info("Step ok - \(step.name, privacy: .public)")
            } catch {
                let errorType = String(describing: type(of: error))
                AppLogger.startup.error(
                    "Step failed - \(step.name, privacy: .public), error \(errorType, privacy: .public)"
                )

                if !step.blocksLaunch {
                    continue
                }

                return makeFailure(error: error, stepName: step.name)
            }
        }

        return nil
    }

    private func makeFailure(error: Error, stepName: String) -> StartupFailure {
        if let startupFailure = error as? StartupFailure {
            return startupFailure
        }

        return .unexpected(step: stepName)
    }
}
