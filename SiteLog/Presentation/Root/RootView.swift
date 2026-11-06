import DesignSystem
import Inject
import SwiftUI

struct RootView: View {
    @ObserveInjection var inject
    @Environment(\.scenePhase) private var scenePhase

    @State private var splashVM = SplashViewModel(
        sequence: StartupSequence(steps: [])
    )

    // Temporary; RootViewModel replaces this in F01
    enum FakeAccessStep {
        case signIn, faceIDLock, passcode, unlocked
    }

    @State private var accessStep: FakeAccessStep = .signIn

    var body: some View {
        Group {
            switch splashVM.state {
            case .ready:
                accessFlow
            case .running, .failed:
                SplashScreen(viewModel: splashVM)
            }
        }
        .overlay {
            // Hide site photos in the app switcher
            if scenePhase != .active {
                PrivacyOverlayView()
            }
        }
        .modifier(DSTextStyle.body)
        .enableInjection()
    }

    @ViewBuilder private var accessFlow: some View {
        switch accessStep {
        case .signIn:
            SignInScreen {
                accessStep = .faceIDLock
            } onContinueOffline: {
                accessStep = .faceIDLock
            }
        case .faceIDLock:
            FaceIDLockScreen {
                accessStep = .unlocked
            } onEnterPasscode: {
                accessStep = .passcode
            }
        case .passcode:
            PasscodeUnlockScreen { _ in
                accessStep = .unlocked
            }
        case .unlocked:
            #if DEBUG
                MainTabView()
                    // Dev menu reset
                    .environment(
                        \.resetApp,
                        ResetAppAction {
                            accessStep = .signIn
                        }
                    )
            #else
                MainTabView()
            #endif
        }
    }
}

#Preview {
    RootView()
}
