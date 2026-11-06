import DesignSystem
import Inject
import SwiftUI

struct SplashScreen: View {
    @ObserveInjection var inject

    let viewModel: SplashViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .running:
                VStack(spacing: DSSpacing.spacing8) {
                    Image(systemName: "hammer")
                        .modifier(DSTextStyle.iconLarge)
                    ProgressView()
                }

            case .failed:
                VStack(spacing: DSSpacing.spacing8) {
                    Text("access.splash.error")
                        .modifier(DSTextStyle.body)
                    Button("access.splash.try_again") {
                        Task {
                            await viewModel.onAppear()
                        }
                    }
                    .modifier(DSTextStyle.headline)
                    .buttonStyle(.borderedProminent)
                }

            case .ready:
                VStack(spacing: DSSpacing.spacing8) {
                    Text("access.splash.ready")
                        .modifier(DSTextStyle.body)
                }
            }
        }
        .task {
            await viewModel.onAppear()
        }
        .enableInjection()
    }
}

#Preview {
    SplashScreen(viewModel: SplashViewModel())
}
