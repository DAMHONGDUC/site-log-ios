// A1 · Face ID lock

import DesignSystem
import Inject
import SwiftUI

struct FaceIDLockScreen: View {
    @ObserveInjection var inject

    var onUnlock: () -> Void = {}
    var onEnterPasscode: () -> Void = {}

    var body: some View {
        VStack(spacing: DSSpacing.spacing16) {
            Spacer()

            AppMark(size: 72)

            VStack(spacing: DSSpacing.spacing4) {
                Text("access.faceIDLock.sitelogIsLocked")
                    .modifier(DSTextStyle.title)
                Text("access.faceIDLock.unlockToViewSitePhotosAndReports")
                    .modifier(DSTextStyle.footnote)
                    .foregroundStyle(DSColor.textSecondary)
            }

            Image(systemName: "faceid")
                .foregroundStyle(DSColor.textSecondary)
                .padding(.top, DSSpacing.spacing32)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(DSColor.canvas)
        .bottomDock(showsBackground: false) {
            Button(action: onUnlock) {
                Label("access.faceIDLock.unlockWithFaceId", systemImage: "faceid")
            }
            .buttonStyle(.sd(.primary))

            Button("access.faceIDLock.enterPasscode", action: onEnterPasscode)
                .buttonStyle(.sd(.ghost))
        }
        .enableInjection()
    }
}

#Preview {
    FaceIDLockScreen()
}
