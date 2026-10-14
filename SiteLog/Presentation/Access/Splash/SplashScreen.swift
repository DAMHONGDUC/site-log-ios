import Inject
import SwiftUI

struct SplashScreen: View {
    @ObserveInjection var inject

    let viewModel: SplashViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .running:
                VStack {
                    Image(systemName: "hammer", ).font(.largeTitle)
                    ProgressView()
                }

            case .failed:
                VStack {
                    Text("Error")
                    Button("Try again") {
                        Task {
                            await viewModel.onAppear()
                        }
                    }.buttonStyle(.borderedProminent)
                }

            case .ready:
                VStack {
                    Text("Ready")
                }
            }
        }
        .task {
            await viewModel.onAppear()
        }
        .enableInjection()
    }
}
