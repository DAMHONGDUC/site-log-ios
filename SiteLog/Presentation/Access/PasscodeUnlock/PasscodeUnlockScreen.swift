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

            Text("access.passcode_unlock.enter_passcode")
                .modifier(DSTextStyle.title)

            PasscodeDots(filled: code.count)

            Text("access.passcode_unlock.attempts_remaining_notice")
                .modifier(DSTextStyle.footnote)
                .foregroundStyle(DSColor.textSecondary)

            Spacer()

            PasscodeNumberPad(code: $code)

            Button("access.passcode_unlock.forgot_passcode") {}
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
