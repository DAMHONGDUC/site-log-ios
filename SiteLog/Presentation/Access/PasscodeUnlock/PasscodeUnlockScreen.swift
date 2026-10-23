// A3 · Enter passcode

import DesignSystem
import Inject
import SwiftUI

struct PasscodeUnlockScreen: View {
    @ObserveInjection var inject

    var onComplete: (String) -> Void = { _ in }

    @State private var code = ""

    var body: some View {
        VStack(spacing: DSSpacing.spacing24) {
            Spacer()

            AppMark(size: 48)

            Text("access.passcodeUnlock.enterPasscode")
                .modifier(DSTextStyle.title)

            PasscodeDots(filled: code.count)

            Text("access.passcodeUnlock.2TriesLeftBeforeA1MinuteWait")
                .modifier(DSTextStyle.footnote)
                .foregroundStyle(DSColor.textSecondary)

            Spacer()

            PasscodeNumberPad(code: $code)

            Button("access.passcodeUnlock.forgotPasscode") {}
                .modifier(DSTextStyle.footnoteSemibold)
                .foregroundStyle(DSColor.textPrimary)
                .padding(.bottom, DSSpacing.spacing8)
        }
        .frame(maxWidth: .infinity)
        .background(DSColor.canvas)
        .onChange(of: code) { _, newValue in
            if newValue.count == 6 {
                onComplete(newValue)
            }
        }
        .enableInjection()
    }
}

#Preview {
    PasscodeUnlockScreen()
}
