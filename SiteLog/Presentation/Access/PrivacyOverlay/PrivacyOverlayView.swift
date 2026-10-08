//
//  PrivacyOverlayView.swift
//  SiteLog
//
//  Covers the app in the app switcher so site photos don't show.
//

import DesignSystem
import Inject
import SwiftUI

struct PrivacyOverlayView: View {
    @ObserveInjection var inject

    var body: some View {
        ZStack {
            DSColor.canvas
                .ignoresSafeArea()

            AppMark(size: 72)
        }
        .enableInjection()
    }
}

#Preview {
    PrivacyOverlayView()
}
