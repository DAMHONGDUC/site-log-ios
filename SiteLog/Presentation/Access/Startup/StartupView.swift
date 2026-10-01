//
//  StartupView.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 1/10/26.
//

import Inject
import SwiftUI

struct StartupView: View {
    @ObserveInjection var inject

    let viewModel: StartupViewModel

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
