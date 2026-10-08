//
//  AppLockView.swift
//  SiteLog
//
//  S4 · App lock: Lock app, Face ID, Change passcode, Lock after.
//  Values are local UI state; saving them is the view model's job (M3).
//

import DesignSystem
import Inject
import SwiftUI

struct AppLockView: View {
    @ObserveInjection var inject

    @State private var isLockOn = true
    @State private var isFaceIDOn = true
    @State private var lockAfter = "5 minutes"
    @State private var isSetPasscodeShown = false

    private let lockAfterOptions = ["Immediately", "1 minute", "5 minutes", "15 minutes", "1 hour"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                VStack(alignment: .leading, spacing: DSSpacing.small) {
                    VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                        DSSectionHeader(title: "Lock app")
                        toggleRow("Lock app", isOn: $isLockOn)
                        DSDivider()
                        toggleRow("Unlock with Face ID", isOn: $isFaceIDOn)
                        DSDivider()
                        Button {
                            isSetPasscodeShown = true
                        } label: {
                            DSListRow(title: "Change passcode", showsChevron: true)
                        }
                        .buttonStyle(.plain)
                    }
                    footnote("Face ID can fail under a helmet or mask. Your passcode always works.")
                }

                VStack(alignment: .leading, spacing: DSSpacing.small) {
                    VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                        DSSectionHeader(title: "Lock after")
                        ForEach(lockAfterOptions, id: \.self) { option in
                            Button {
                                lockAfter = option
                            } label: {
                                DSListRow(title: option) {
                                    DSRadioMark(isOn: lockAfter == option)
                                }
                            }
                            .buttonStyle(.plain)
                            DSDivider()
                        }
                    }
                    footnote("Counted from when you leave SiteLog. Uploads keep running while it’s locked.")
                }
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
        .navigationTitle("App lock")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isSetPasscodeShown) {
            SetPasscodeView()
        }
        .enableInjection()
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .tint(DSColor.success)
            .frame(minHeight: DSSize.rowMinHeight)
            .padding(.horizontal, DSSpacing.regular)
    }

    private func footnote(_ text: String) -> some View {
        Text(text)
            .font(DSFont.footnote)
            .foregroundStyle(DSColor.textSecondary)
            .padding(.horizontal, DSSpacing.regular)
    }
}

#Preview {
    NavigationStack {
        AppLockView()
    }
}
