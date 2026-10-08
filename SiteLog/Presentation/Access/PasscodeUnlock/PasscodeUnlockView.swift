//
//  PasscodeUnlockView.swift
//  SiteLog
//
//  A3 · Enter passcode. The view only collects 6 digits and hands them over;
//  checking them and the tries-left text belong to the view model.
//

import DesignSystem
import Inject
import SwiftUI

struct PasscodeUnlockView: View {
    @ObserveInjection var inject

    var onComplete: (String) -> Void = { _ in }

    @State private var code = ""

    var body: some View {
        VStack(spacing: DSSpacing.large) {
            Spacer()

            AppMark(size: 48)

            Text("Enter passcode")
                .font(.title2.bold())

            PasscodeDots(filled: code.count)

            Text("2 tries left before a 1-minute wait")
                .font(DSFont.footnote)
                .foregroundStyle(DSColor.textSecondary)

            Spacer()

            PasscodeNumberPad(code: $code)

            Button("Forgot passcode?") {}
                .font(DSFont.footnote.weight(.semibold))
                .foregroundStyle(DSColor.textPrimary)
                .padding(.bottom, DSSpacing.small)
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
    PasscodeUnlockView()
}
