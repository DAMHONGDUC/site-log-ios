// A3 · Enter passcode

import SystemDesign
import Inject
import SwiftUI

struct PasscodeUnlockView: View {
    @ObserveInjection var inject

    var onComplete: (String) -> Void = { _ in }

    @State private var code = ""

    var body: some View {
        VStack(spacing: SDSpacing.large) {
            Spacer()

            AppMark(size: 48)

            Text("Enter passcode")
                .font(.title2.bold())

            PasscodeDots(filled: code.count)

            Text("2 tries left before a 1-minute wait")
                .font(SDFont.footnote)
                .foregroundStyle(SDColor.textSecondary)

            Spacer()

            PasscodeNumberPad(code: $code)

            Button("Forgot passcode?") {}
                .font(SDFont.footnote.weight(.semibold))
                .foregroundStyle(SDColor.textPrimary)
                .padding(.bottom, SDSpacing.small)
        }
        .frame(maxWidth: .infinity)
        .background(SDColor.canvas)
        .onChange(of: code) { _, newValue in
            if newValue.count == 6 {
                onComplete(newValue)
            }
        }
        .enableInjection()
    }
}

#Preview {
    PasscodeUnlockView()
}
