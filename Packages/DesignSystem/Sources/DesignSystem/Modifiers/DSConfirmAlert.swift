//
//  ConfirmAlert.swift
//  DesignSystem
//
//  Created by Duc Dam Dev on 23/10/26.
//

import SwiftUI

private struct DSConfirmAlertView: ViewModifier {
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let confirmText: LocalizedStringKey
    let cancelText: LocalizedStringKey
    let onConfirm: () -> Void
    let onCancel: () -> Void
    let isPresented: Binding<Bool>

    func body(content: Content) -> some View {
        content.alert(
            title,
            isPresented: isPresented,
            actions: {
                Button(
                    confirmText,
                    role: .destructive,
                    action: {
                        onConfirm()
                    }
                )
                Button(
                    cancelText,
                    role: .cancel,
                    action: {
                        onCancel()
                    }
                )
            },
            message: {
                Text(description)
            }
        )
    }
}

extension View {
    public func confirmAlert(
        title: LocalizedStringKey,
        description: LocalizedStringKey,
        confirmText: LocalizedStringKey,
        cancelText: LocalizedStringKey,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void = {},
        isPresented: Binding<Bool>
    ) -> some View {
        return self.modifier(
            DSConfirmAlertView(
                title: title,
                description: description,
                confirmText: confirmText,
                cancelText: cancelText,
                onConfirm: onConfirm,
                onCancel: onCancel,
                isPresented: isPresented
            )
        )
    }
}
