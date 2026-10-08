//
//  SignInView.swift
//  SiteLog
//
//  A2 · Sign in (optional). Buttons only call closures; real auth arrives in M5.
//

import DesignSystem
import Inject
import SwiftUI

struct SignInView: View {
    @ObserveInjection var inject

    var onSignIn: () -> Void = {}
    var onContinueOffline: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.small) {
            AppMark(size: 56)
                .padding(.top)

            Text("Your site log,\non every device.")
                .font(DSFont.largeTitle)

            Text("Sign in to back up projects and hand off between iPhone and iPad. Everything still works offline without an account.")
                .font(DSFont.subhead)
                .foregroundStyle(DSColor.textSecondary)

            Spacer()

            VStack(alignment: .leading, spacing: DSSpacing.medium) {
                featureRow(systemImage: "wifi.slash", text: "Works with zero signal")
                featureRow(systemImage: "checkmark.shield", text: "Photos hashed at capture")
                featureRow(systemImage: "doc.text", text: "Signed PDF in one tap")
            }
        }
        .padding(.horizontal, DSSpacing.regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColor.canvas)
        .bottomDock(showsBackground: false) {
            Button(action: onSignIn) {
                Label("Sign in with Apple", systemImage: "apple.logo")
            }
            .buttonStyle(.ds(.primary))

            Button(action: onSignIn) {
                Label("Continue with email", systemImage: "envelope")
            }
            .buttonStyle(.ds(.secondary))

            Button("Continue offline", action: onContinueOffline)
                .buttonStyle(.ds(.ghost))
        }
        .enableInjection()
    }

    private func featureRow(systemImage: String, text: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(DSFont.subhead)
    }
}

#Preview {
    SignInView()
}
