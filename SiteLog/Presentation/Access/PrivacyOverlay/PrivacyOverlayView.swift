import Inject
import SwiftUI
import SystemDesign

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
