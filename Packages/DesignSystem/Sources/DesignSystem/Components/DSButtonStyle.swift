import SwiftUI

// Usage: .buttonStyle(.sd(.primary)) or .sd(.secondary, small: true)
public struct DSButtonStyle: ButtonStyle {
    public enum Kind: CaseIterable, Sendable {
        case primary
        // Capture button only
        case hiVis
        case secondary
        case ghost
        case danger
    }

    let kind: Kind
    // 34 pt capsule for row actions ("Pair", "Retry")
    let small: Bool

    public init(kind: Kind, small: Bool = false) {
        self.kind = kind
        self.small = small
    }

    public func makeBody(configuration: Configuration) -> some View {
        // Separate view: only a View can read isEnabled
        DSButtonBody(
            kind: kind,
            small: small,
            label: configuration.label,
            isPressed: configuration.isPressed
        )
    }
}

extension ButtonStyle where Self == DSButtonStyle {
    public static func sd(_ kind: DSButtonStyle.Kind, small: Bool = false) -> DSButtonStyle {
        return DSButtonStyle(kind: kind, small: small)
    }
}

private struct DSButtonBody: View {
    let kind: DSButtonStyle.Kind
    let small: Bool
    let label: ButtonStyleConfiguration.Label
    let isPressed: Bool

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        if small {
            label
                .font(DSFont.subhead.weight(.semibold))
                .foregroundStyle(textColor)
                .padding(.horizontal, 14)
                .frame(height: DSSize.smallButtonHeight)
                .background(background, in: Capsule())
                .opacity(opacity)
        } else {
            label
                .font(font)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: DSSize.buttonHeight)
                .background(background, in: RoundedRectangle(cornerRadius: DSRadius.button))
                .contentShape(RoundedRectangle(cornerRadius: DSRadius.button))
                .opacity(opacity)
        }
    }

    private var font: Font {
        if kind == .ghost {
            return DSFont.body.weight(.medium)
        }
        return DSFont.headline
    }

    private var opacity: Double {
        if !isEnabled {
            return 0.3
        }
        if isPressed {
            return 0.7
        }
        return 1
    }

    private var textColor: Color {
        switch kind {
        case .primary:
            return DSColor.onPrimary
        case .hiVis:
            return DSColor.onHiVis
        case .secondary, .ghost:
            return DSColor.textPrimary
        case .danger:
            return DSColor.critical
        }
    }

    private var background: Color {
        switch kind {
        case .primary:
            return DSColor.textPrimary
        case .hiVis:
            return DSColor.hiVis
        case .secondary:
            return DSColor.fill
        case .ghost, .danger:
            return Color.clear
        }
    }
}

#Preview {
    VStack(spacing: DSSpacing.medium) {
        Button("Create project") {}
            .buttonStyle(.sd(.primary))
        Button("Capture") {}
            .buttonStyle(.sd(.hiVis))
        Button("Continue with email") {}
            .buttonStyle(.sd(.secondary))
        Button("Continue offline") {}
            .buttonStyle(.sd(.ghost))
        Button("Delete project") {}
            .buttonStyle(.sd(.danger))
        Button("Retry") {}
            .buttonStyle(.sd(.secondary, small: true))
        Button("Disabled") {}
            .buttonStyle(.sd(.primary))
            .disabled(true)
    }
    .padding(DSSpacing.regular)
}
