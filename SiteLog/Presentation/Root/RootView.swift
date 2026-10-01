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

    @State private var startupVM = StartupViewModel(
        sequence: StartupSequence(steps: [])
    )

    var body: some View {
        Group {
            switch startupVM.state {
            case .ready:
                MainTabView()
            case .running, .failed:
                StartupView(viewModel: startupVM)
            }
        }
        .enableInjection()
    }
}
