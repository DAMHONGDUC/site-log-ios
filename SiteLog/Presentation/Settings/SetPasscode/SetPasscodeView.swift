// S5 · Set passcode

import SystemDesign
import Inject
import SwiftUI

struct SetPasscodeView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var code = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: SDSpacing.large) {
                Spacer()

                Text("Enter a 6-digit passcode")
                    .font(.title2.bold())

                PasscodeDots(filled: code.count)

                Text("You’ll use it when Face ID can’t see you. It stays on this iPhone and is never uploaded.")
                    .font(SDFont.footnote)
                    .foregroundStyle(SDColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)

                Spacer()

                PasscodeNumberPad(code: $code)
                    .padding(.bottom, SDSpacing.large)
            }
            .frame(maxWidth: .infinity)
            .background(SDColor.canvas)
            .navigationTitle("Set passcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
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
    SetPasscodeView()
}
