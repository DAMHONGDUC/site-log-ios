// A1 · Face ID lock

import SystemDesign
import Inject
import SwiftUI

struct FaceIDLockView: View {
    @ObserveInjection var inject

    var onUnlock: () -> Void = {}
    var onEnterPasscode: () -> Void = {}

    var body: some View {
        VStack(spacing: SDSpacing.regular) {
            Spacer()

            AppMark(size: 72)

            VStack(spacing: SDSpacing.tiny) {
                Text("SiteLog is locked")
                    .font(.title2.bold())
                Text("Unlock to view site photos and reports.")
                    .font(SDFont.footnote)
                    .foregroundStyle(SDColor.textSecondary)
            }

            Image(systemName: "faceid")
                .foregroundStyle(SDColor.textSecondary)
                .padding(.top, SDSpacing.xLarge)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(SDColor.canvas)
        .bottomDock(showsBackground: false) {
            Button(action: onUnlock) {
                Label("Unlock with Face ID", systemImage: "faceid")
            }
            .buttonStyle(.sd(.primary))

            Button("Enter passcode", action: onEnterPasscode)
                .buttonStyle(.sd(.ghost))
        }
        .enableInjection()
    }
}

#Preview {
    FaceIDLockView()
}
