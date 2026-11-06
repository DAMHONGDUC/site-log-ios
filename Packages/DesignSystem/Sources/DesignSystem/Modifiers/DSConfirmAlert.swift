import SwiftUI

// The four texts of a confirm alert, grouped so the modifier stays short.
public struct DSConfirmAlertText {
    public let title: LocalizedStringKey
    public let description: LocalizedStringKey
    public let confirmText: LocalizedStringKey
    public let cancelText: LocalizedStringKey

    public init(
        title: LocalizedStringKey,
        description: LocalizedStringKey,
        confirmText: LocalizedStringKey,
        cancelText: LocalizedStringKey
    ) {
        self.title = title
        self.description = description
        self.confirmText = confirmText
        self.cancelText = cancelText
    }
}

private struct DSConfirmAlertView: ViewModifier {
    let text: DSConfirmAlertText
    let onConfirm: () -> Void
    let onCancel: () -> Void
    let isPresented: Binding<Bool>

    func body(content: Content) -> some View {
        content.alert(
            text.title,
            isPresented: isPresented,
            actions: {
                Button(
                    text.confirmText,
                    role: .destructive,
                    action: {
                        onConfirm()
                    }
                )
                Button(
                    text.cancelText,
                    role: .cancel,
                    action: {
                        onCancel()
                    }
                )
            },
            message: {
                Text(text.description)
            }
        )
    }
}

extension View {
    public func confirmAlert(
        _ text: DSConfirmAlertText,
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void = {}
    ) -> some View {
        return self.modifier(
            DSConfirmAlertView(
                text: text,
                onConfirm: onConfirm,
                onCancel: onCancel,
                isPresented: isPresented
            )
        )
    }
}
