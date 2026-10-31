// S4 · App lock

import DesignSystem
import Inject
import SwiftUI

struct AppLockScreen: View {
    @ObserveInjection var inject

    @State private var isLockOn = true
    @State private var isFaceIDOn = true
    @State private var lockAfter = "settings.app_lock.five_minutes"
    @State private var isSetPasscodeShown = false

    private let lockAfterOptions = [
        "settings.app_lock.immediately", "settings.app_lock.one_minute",
        "settings.app_lock.five_minutes", "settings.app_lock.fifteen_minutes",
        "settings.app_lock.one_hour",
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
                    VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                        DSSectionHeader(title: String(localized: "settings.app_lock.lock_app"))
                        toggleRow(String(localized: "settings.app_lock.lock_app"), isOn: $isLockOn)
                        DSDivider()
                        toggleRow(
                            String(localized: "settings.app_lock.unlock_with_face_id"),
                            isOn: $isFaceIDOn
                        )
                        DSDivider()
                        Button {
                            isSetPasscodeShown = true
                        } label: {
                            DSListRow(
                                title: String(localized: "settings.app_lock.change_passcode"),
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    footnote(
                        String(
                            localized:
                                "settings.app_lock.passcode_note"
                        )
                    )
                }

                VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
                    VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                        DSSectionHeader(title: String(localized: "settings.app_lock.lock_after"))
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
                                "settings.app_lock.lock_timer_note"
                        )
                    )
                }
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("settings.app_lock.app_lock")
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
