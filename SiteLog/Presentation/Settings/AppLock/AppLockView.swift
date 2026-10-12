// S4 · App lock

import SystemDesign
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
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                VStack(alignment: .leading, spacing: SDSpacing.small) {
                    VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                        SDSectionHeader(title: "Lock app")
                        toggleRow("Lock app", isOn: $isLockOn)
                        SDDivider()
                        toggleRow("Unlock with Face ID", isOn: $isFaceIDOn)
                        SDDivider()
                        Button {
                            isSetPasscodeShown = true
                        } label: {
                            SDListRow(title: "Change passcode", showsChevron: true)
                        }
                        .buttonStyle(.plain)
                    }
                    footnote("Face ID can fail under a helmet or mask. Your passcode always works.")
                }

                VStack(alignment: .leading, spacing: SDSpacing.small) {
                    VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                        SDSectionHeader(title: "Lock after")
                        ForEach(lockAfterOptions, id: \.self) { option in
                            Button {
                                lockAfter = option
                            } label: {
                                SDListRow(title: option) {
                                    SDRadioMark(isOn: lockAfter == option)
                                }
                            }
                            .buttonStyle(.plain)
                            SDDivider()
                        }
                    }
                    footnote("Counted from when you leave SiteLog. Uploads keep running while it’s locked.")
                }
            }
            .padding(.vertical, SDSpacing.small)
        }
        .background(SDColor.canvas)
        .navigationTitle("App lock")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isSetPasscodeShown) {
            SetPasscodeView()
        }
        .enableInjection()
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .tint(SDColor.success)
            .frame(minHeight: SDSize.rowMinHeight)
            .padding(.horizontal, SDSpacing.regular)
    }

    private func footnote(_ text: String) -> some View {
        Text(text)
            .font(SDFont.footnote)
            .foregroundStyle(SDColor.textSecondary)
            .padding(.horizontal, SDSpacing.regular)
    }
}

#Preview {
    NavigationStack {
        AppLockView()
    }
}
