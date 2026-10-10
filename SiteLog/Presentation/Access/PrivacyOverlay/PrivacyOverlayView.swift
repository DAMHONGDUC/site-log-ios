import SystemDesign
import Inject
import SwiftUI

struct PrivacyOverlayView: View {
    @ObserveInjection var inject

    var body: some View {
        ZStack {
            SDColor.canvas
                .ignoresSafeArea()

            AppMark(size: 72)
        }
        .enableInjection()
    }
}

#Preview {
    PrivacyOverlayView()
}
