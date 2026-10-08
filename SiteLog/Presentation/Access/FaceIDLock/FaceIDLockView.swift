//
//  FaceIDLockView.swift
//  SiteLog
//
//  A1 · Face ID lock. Face ID itself (LAContext) arrives with the view model.
//

import DesignSystem
import Inject
import SwiftUI

struct FaceIDLockView: View {
    @ObserveInjection var inject

    var onUnlock: () -> Void = {}
    var onEnterPasscode: () -> Void = {}

    var body: some View {
        VStack(spacing: DSSpacing.regular) {
            Spacer()

            AppMark(size: 72)

            VStack(spacing: DSSpacing.tiny) {
                Text("SiteLog is locked")
                    .font(.title2.bold())
                Text("Unlock to view site photos and reports.")
                    .font(DSFont.footnote)
                    .foregroundStyle(DSColor.textSecondary)
            }

            Image(systemName: "faceid")
                .foregroundStyle(DSColor.textSecondary)
                .padding(.top, DSSpacing.xLarge)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(DSColor.canvas)
        .bottomDock(showsBackground: false) {
            Button(action: onUnlock) {
                Label("Unlock with Face ID", systemImage: "faceid")
            }
            .buttonStyle(.ds(.primary))

            Button("Enter passcode", action: onEnterPasscode)
                .buttonStyle(.ds(.ghost))
        }
        .enableInjection()
    }
}

#Preview {
    FaceIDLockView()
}
