// S5 · Set passcode

import DesignSystem
import Inject
import SwiftUI

struct SetPasscodeScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var code = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: DSSpacing.spacing24) {
                Spacer()

                Text("settings.setPasscode.enterA6DigitPasscode")
                    .modifier(DSTextStyle.title)

                PasscodeDots(filled: code.count)

                Text(
                    "settings.setPasscode.youLlUseItWhenFaceIdCanTSeeYouItStaysOnThisIphoneAndIsNeverUploaded"
                )
                .modifier(DSTextStyle.footnote)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

                Spacer()

                PasscodeNumberPad(code: $code)
                    .padding(.bottom, DSSpacing.spacing24)
            }
            .frame(maxWidth: .infinity)
            .background(DSColor.canvas)
            .navigationTitle("settings.setPasscode.setPasscode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("settings.setPasscode.cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: code) { _, newValue in
                if newValue.count == 6 {
                    dismiss()
                }
            }
        }
        .enableInjection()
    }
}

#Preview {
    SetPasscodeScreen()
}
