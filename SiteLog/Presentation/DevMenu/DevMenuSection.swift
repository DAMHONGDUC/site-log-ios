//
//  DevMenuSection.swift
//  SiteLog
//
//  Debug-only "Debug" section at the bottom of Settings:
//  seed data, delete all data, reset the app.
//

#if DEBUG

import DesignSystem
import Inject
import os
import SwiftUI

struct DevMenuSection: View {
    @ObserveInjection var inject
    @Environment(\.resetApp) private var resetApp

    var actions: any DevDataActions = NoopDevDataActions()

    // Which destructive action is waiting for confirmation
    enum PendingAction: String {
        case reset = "Reset the app"
        case deleteAll = "Delete all data"
    }

    @State private var pendingAction: PendingAction?
    @State private var isWorking = false
    @State private var lastResult: String?

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.tiny) {
            DSSectionHeader(title: "Debug")

            actionRow(
                title: "Seed data",
                subtitle: "Add sample projects, sessions and issues",
                systemImage: "tray.and.arrow.down"
            ) {
                run(name: "Seed data") {
                    await actions.seedData()
                }
            }
            DSDivider()

            actionRow(
                title: "Delete all data",
                subtitle: "Remove every project, photo and setting",
                systemImage: "trash",
                isDestructive: true
            ) {
                pendingAction = .deleteAll
            }
            DSDivider()

            actionRow(
                title: "Reset the app",
                subtitle: "Delete all data, then start again from onboarding",
                systemImage: "arrow.counterclockwise",
                isDestructive: true
            ) {
                pendingAction = .reset
            }

            if let lastResult {
                Text(lastResult)
                    .font(DSFont.footnote)
                    .foregroundStyle(DSColor.textSecondary)
                    .padding(.horizontal, DSSpacing.regular)
                    .padding(.top, DSSpacing.medium)
            }
        }
        .disabled(isWorking)
        .overlay {
            if isWorking {
                ProgressView()
            }
        }
        .alert(
            "\(pendingAction?.rawValue ?? "")?",
            isPresented: isConfirmShown,
            presenting: pendingAction
        ) { action in
            Button(action.rawValue, role: .destructive) {
                confirm(action)
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("This can’t be undone.")
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
            DSListRow(title: title, subtitle: subtitle) {
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                    .foregroundStyle(isDestructive ? DSColor.critical : DSColor.textPrimary)
                    .frame(width: 26)
            }
        }
        .buttonStyle(.plain)
    }

    // true while an action waits for confirmation
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
            run(name: "Delete all data") {
                await actions.deleteAllData()
            }
        case .reset:
            run(name: "Reset the app") {
                await actions.deleteAllData()
            } then: {
                // Back to onboarding; Settings goes away with the tabs
                resetApp()
            }
        }
    }

    // Runs one action with a spinner and logs start / finish
    private func run(name: String, work: @escaping () async -> Void, then finish: @escaping () -> Void = {}) {
        AppLogger.devMenu.info("Start - \(name, privacy: .public)")
        isWorking = true

        Task {
            await work()
            isWorking = false
            lastResult = "\(name) finished"
            AppLogger.devMenu.info("Done - \(name, privacy: .public)")
            finish()
        }
    }
}

#Preview {
    DevMenuSection()
}

#endif
