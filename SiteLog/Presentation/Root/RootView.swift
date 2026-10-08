//
//  RootView.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 30/9/26.
//

import Inject
import SwiftUI

struct RootView: View {
    @ObserveInjection var inject
    @Environment(\.scenePhase) private var scenePhase

    @State private var startupVM = StartupViewModel(
        sequence: StartupSequence(steps: [])
    )

    // P07: UI-only access flow so every screen can be clicked through.
    // RootViewModel replaces this with AccessSettings (welcome seen, lock on, Face ID).
    enum FakeAccessStep {
        case signIn, faceIDLock, passcode, unlocked
    }

    @State private var accessStep: FakeAccessStep = .signIn

    var body: some View {
        Group {
            switch startupVM.state {
            case .ready:
                accessFlow
            case .running, .failed:
                StartupView(viewModel: startupVM)
            }
        }
        .overlay {
            // Hide site photos in the app switcher
            if scenePhase != .active {
                PrivacyOverlayView()
            }
        }
        .enableInjection()
    }

    @ViewBuilder private var accessFlow: some View {
        switch accessStep {
        case .signIn:
            SignInView {
                accessStep = .faceIDLock
            } onContinueOffline: {
                accessStep = .faceIDLock
            }
        case .faceIDLock:
            FaceIDLockView {
                accessStep = .unlocked
            } onEnterPasscode: {
                accessStep = .passcode
            }
        case .passcode:
            PasscodeUnlockView { _ in
                accessStep = .unlocked
            }
        case .unlocked:
            MainTabView()
        }
    }
}
