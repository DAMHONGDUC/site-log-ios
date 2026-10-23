// S4 · App lock

import DesignSystem
import Inject
import SwiftUI

struct AppLockScreen: View {
    @ObserveInjection var inject

    @State private var isLockOn = true
    @State private var isFaceIDOn = true
    @State private var lockAfter = "settings.appLock.fiveMinutes"
    @State private var isSetPasscodeShown = false

    private let lockAfterOptions = [
        "settings.appLock.immediately", "settings.appLock.oneMinute",
        "settings.appLock.fiveMinutes", "settings.appLock.fifteenMinutes",
        "settings.appLock.oneHour",
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
                    VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                        DSSectionHeader(title: String(localized: "settings.appLock.lockApp"))
                        toggleRow(String(localized: "settings.appLock.lockApp"), isOn: $isLockOn)
                        DSDivider()
                        toggleRow(
                            String(localized: "settings.appLock.unlockWithFaceId"),
                            isOn: $isFaceIDOn
                        )
                        DSDivider()
                        Button {
                            isSetPasscodeShown = true
                        } label: {
                            DSListRow(
                                title: String(localized: "settings.appLock.changePasscode"),
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    footnote(
                        String(
                            localized:
                                "settings.appLock.faceIdCanFailUnderAHelmetOrMaskYourPasscodeAlwaysWorks"
                        )
                    )
                }

                VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
                    VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                        DSSectionHeader(title: String(localized: "settings.appLock.lockAfter"))
                        ForEach(lockAfterOptions, id: \.self) { option in
                            Button {
                                lockAfter = option
                            } label: {
                                DSListRow(title: NSLocalizedString(option, comment: "")) {
                                    DSRadioMark(isOn: lockAfter == option)
                                }
                            }
                            .buttonStyle(.plain)
                            DSDivider()
                        }
                    }
                    footnote(
                        String(
                            localized:
                                "settings.appLock.countedFromWhenYouLeaveSitelogUploadsKeepRunningWhileItSLocked"
                        )
                    )
                }
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("settings.appLock.appLock")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isSetPasscodeShown) {
            SetPasscodeScreen()
        }
        .enableInjection()
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .tint(DSColor.success)
            .frame(minHeight: DSSpacing.spacing52)
            .padding(.horizontal, DSSpacing.spacing16)
    }

    private func footnote(_ text: String) -> some View {
        Text(text)
            .modifier(DSTextStyle.footnote)
            .foregroundStyle(DSColor.textSecondary)
            .padding(.horizontal, DSSpacing.spacing16)
    }
}

#Preview {
    NavigationStack {
        AppLockScreen()
    }
}
