//
//  StartupViewModel.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 1/10/26.
//

import Observation

@MainActor @Observable
final class StartupViewModel {
    enum State {
        case running, ready
        case failed(StartupFailure)
    }
    private(set) var state: State = .running

    @ObservationIgnored private let sequence: StartupSequence

    init(sequence: StartupSequence = StartupSequence(steps: [])) {
        self.sequence = sequence

    }

    func onAppear() async {
        state = .running

        let failure: StartupFailure? = await sequence.run()

        if let failure {
            state = .failed(failure)
        } else {
            state = .ready
        }
    }
}
