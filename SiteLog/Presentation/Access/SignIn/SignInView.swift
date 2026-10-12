// A2 · Sign in

import SystemDesign
import Inject
import SwiftUI

struct SignInView: View {
    @ObserveInjection var inject

    var onSignIn: () -> Void = {}
    var onContinueOffline: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.small) {
            AppMark(size: 56)
                .padding(.top)

            Text("Your site log,\non every device.")
                .font(SDFont.largeTitle)

            Text("Sign in to back up projects and hand off between iPhone and iPad. Everything still works offline without an account.")
                .font(SDFont.subhead)
                .foregroundStyle(SDColor.textSecondary)

            Spacer()

            VStack(alignment: .leading, spacing: SDSpacing.medium) {
                featureRow(systemImage: "wifi.slash", text: "Works with zero signal")
                featureRow(systemImage: "checkmark.shield", text: "Photos hashed at capture")
                featureRow(systemImage: "doc.text", text: "Signed PDF in one tap")
            }
        }
        .padding(.horizontal, SDSpacing.regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SDColor.canvas)
        .bottomDock(showsBackground: false) {
            Button(action: onSignIn) {
                Label("Sign in with Apple", systemImage: "apple.logo")
            }
            .buttonStyle(.sd(.primary))

            Button(action: onSignIn) {
                Label("Continue with email", systemImage: "envelope")
            }
            .buttonStyle(.sd(.secondary))

            Button("Continue offline", action: onContinueOffline)
                .buttonStyle(.sd(.ghost))
        }
        .enableInjection()
    }

    private func featureRow(systemImage: String, text: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(SDFont.subhead)
    }
}

#Preview {
    SignInView()
}
