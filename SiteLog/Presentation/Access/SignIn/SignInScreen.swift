// A2 · Sign in

import DesignSystem
import Inject
import SwiftUI

struct SignInScreen: View {
    @ObserveInjection var inject

    var onSignIn: () -> Void = {}
    var onContinueOffline: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
            AppMark(size: 56)
                .padding(.top)

            Text("access.sign_in.title")
                .modifier(DSTextStyle.largeTitle)

            Text(
                "access.sign_in.description"
            )
            .modifier(DSTextStyle.subhead)
            .foregroundStyle(DSColor.textSecondary)

            Spacer()

            VStack(alignment: .leading, spacing: DSSpacing.spacing12) {
                featureRow(
                    systemImage: "wifi.slash",
                    text: String(localized: "access.sign_in.benefit_1")
                )
                featureRow(
                    systemImage: "checkmark.shield",
                    text: String(localized: "access.sign_in.benefit_2")
                )
                featureRow(
                    systemImage: "doc.text",
                    text: String(localized: "access.sign_in.benefit_3")
                )
            }
        }
        .padding(.horizontal, DSSpacing.spacing16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColor.canvas)
        .bottomDock(showsBackground: false) {
            Button(action: onSignIn) {
                Label("access.sign_in.primary_action", systemImage: "apple.logo")
            }
            .buttonStyle(.sd(.primary))

            Button(action: onSignIn) {
                Label("access.sign_in.secondary_action", systemImage: "envelope")
            }
            .buttonStyle(.sd(.secondary))

            Button("access.sign_in.tertiary_action", action: onContinueOffline)
                .buttonStyle(.sd(.ghost))
        }
        .enableInjection()
    }

    private func featureRow(systemImage: String, text: String) -> some View {
        Label(text, systemImage: systemImage)
            .modifier(DSTextStyle.subhead)
    }
}

#Preview {
    SignInScreen()
}
