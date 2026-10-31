#if DEBUG

    import Core
    import DesignSystem
    import FactoryKit
    import Inject
    import os
    import SwiftUI

    struct DevMenuSection: View {
        @ObserveInjection var inject
        @Environment(\.resetApp) private var resetApp

        @State private var viewModel = DevMenuViewModel(
            resetAllAccessDataUseCase: Container.shared.resetAllAccessDataUseCase(),
            seedAccessDataUseCase: Container.shared.seedAccessDataUseCase()
        )

        enum PendingAction: String {
            case reset = "devmenu.action.reset"
            case deleteAll = "devmenu.action.delete_all"

            var title: String {
                NSLocalizedString(rawValue, comment: "")
            }
        }

        @State private var pendingAction: PendingAction?
        @State private var isWorking = false
        @State private var lastResult: String?

        var body: some View {
            VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                DSSectionHeader(title: String(localized: "devmenu.dev_menu_section.debug"))

                actionRow(
                    title: String(localized: "devmenu.action.seed_data"),
                    subtitle: String(localized: "devmenu.action.seed_data_description"),
                    systemImage: "tray.and.arrow.down"
                ) {
                    run(name: String(localized: "devmenu.action.seed_data")) {
                        await viewModel.seedData()
                    }
                }
                DSDivider()

                actionRow(
                    title: String(localized: "devmenu.action.delete_all"),
                    subtitle: String(localized: "devmenu.action.delete_all_description"),
                    systemImage: "trash",
                    isDestructive: true
                ) {
                    pendingAction = .deleteAll
                }
                DSDivider()

                actionRow(
                    title: String(localized: "devmenu.action.reset"),
                    subtitle: String(localized: "devmenu.action.reset_description"),
                    systemImage: "arrow.counterclockwise",
                    isDestructive: true
                ) {
                    pendingAction = .reset
                }

                if let lastResult {
                    Text(lastResult)
                        .modifier(DSTextStyle.footnote)
                        .foregroundStyle(DSColor.textSecondary)
                        .padding(.horizontal, DSSpacing.spacing16)
                        .padding(.top, DSSpacing.spacing12)
                }
            }
            .disabled(isWorking)
            .overlay {
                if isWorking {
                    ProgressView()
                }
            }
            .alert(confirmationTitle, isPresented: isConfirmShown, presenting: pendingAction) {
                action in
                Button(action.title, role: .destructive) {
                    confirm(action)
                }
                Button("devmenu.dev_menu_section.cancel", role: .cancel) {}
            } message: { _ in
                Text("devmenu.dev_menu_section.this_can_t_be_undone")
            }
            .enableInjection()
        }

        private func actionRow(
            title: String,
            subtitle: String,
            systemImage: String,
            isDestructive: Bool = false,
            action: @escaping () -> Void
        ) -> some View {
            Button(action: action) {
                DSListRow(
                    title: title,
                    subtitle: subtitle,
                    leading: {
                        Image(systemName: systemImage)
                            .modifier(DSTextStyle.iconMedium)
                            .foregroundStyle(isDestructive ? DSColor.critical : DSColor.textPrimary)
                            .frame(width: DSSpacing.spacing26)
                    }
                )
            }
            .buttonStyle(.plain)
        }

        private var confirmationTitle: String {
            guard let pendingAction else { return "" }
            return String.localizedStringWithFormat(
                String(localized: "devmenu.confirm_action"),
                pendingAction.title
            )
        }

        private var isConfirmShown: Binding<Bool> {
            Binding(
                get: { pendingAction != nil },
                set: { isShown in
                    if !isShown {
                        pendingAction = nil
                    }
                }
            )
        }

        private func confirm(_ action: PendingAction) {
            switch action {
            case .deleteAll:
                run(name: String(localized: "devmenu.action.delete_all")) {
                    await viewModel.deleteAllData()
                }
            case .reset:
                run(
                    name: String(localized: "devmenu.action.reset"),
                    work: {
                        await viewModel.deleteAllData()
                    },
                    then: {
                        resetApp()
                    }
                )
            }
        }

        private func run(
            name: String,
            work: @escaping () async -> Void,
            then finish: @escaping () -> Void = {}
        ) {
            AppLogger.devMenu.info("Start - \(name, privacy: .public)")
            isWorking = true

            Task {
                await work()
                isWorking = false
                lastResult = String.localizedStringWithFormat(
                    String(localized: "devmenu.action_finished"),
                    name
                )
                AppLogger.devMenu.info("Done - \(name, privacy: .public)")
                finish()
            }
        }
    }

    #Preview {
        DevMenuSection()
    }

#endif
