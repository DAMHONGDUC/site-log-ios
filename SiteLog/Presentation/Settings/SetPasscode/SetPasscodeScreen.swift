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

                Text("settings.set_passcode.enter_a6_digit_passcode")
                    .modifier(DSTextStyle.title)

                PasscodeDots(filled: code.count)

                Text(
                    "settings.set_passcode.passcode_privacy_note"
                )
                .modifier(DSTextStyle.footnote)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: DSSpacing.spacing280)

                Spacer()

                PasscodeNumberPad(code: $code)
                    .padding(.bottom, DSSpacing.spacing24)
            }
            .frame(maxWidth: .infinity)
            .background(DSColor.canvas)
            .navigationTitle("settings.set_passcode.set_passcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("settings.set_passcode.cancel") {
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
