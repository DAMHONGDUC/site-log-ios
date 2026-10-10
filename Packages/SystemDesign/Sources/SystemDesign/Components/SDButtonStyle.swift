import SwiftUI

// Usage: .buttonStyle(.sd(.primary)) or .sd(.secondary, small: true)
public struct SDButtonStyle: ButtonStyle {
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
        SDButtonBody(kind: kind, small: small, label: configuration.label, isPressed: configuration.isPressed)
    }
}

extension ButtonStyle where Self == SDButtonStyle {
    public static func sd(_ kind: SDButtonStyle.Kind, small: Bool = false) -> SDButtonStyle {
        return SDButtonStyle(kind: kind, small: small)
    }
}

private struct SDButtonBody: View {
    let kind: SDButtonStyle.Kind
    let small: Bool
    let label: ButtonStyleConfiguration.Label
    let isPressed: Bool

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        if small {
            label
                .font(SDFont.subhead.weight(.semibold))
                .foregroundStyle(textColor)
                .padding(.horizontal, 14)
                .frame(height: SDSize.smallButtonHeight)
                .background(background, in: Capsule())
                .opacity(opacity)
        } else {
            label
                .font(font)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: SDSize.buttonHeight)
                .background(background, in: RoundedRectangle(cornerRadius: SDRadius.button))
                .contentShape(RoundedRectangle(cornerRadius: SDRadius.button))
                .opacity(opacity)
        }
    }

    private var font: Font {
        if kind == .ghost {
            return SDFont.body.weight(.medium)
        }
        return SDFont.headline
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
            return SDColor.onPrimary
        case .hiVis:
            return SDColor.onHiVis
        case .secondary, .ghost:
            return SDColor.textPrimary
        case .danger:
            return SDColor.critical
        }
    }

    private var background: Color {
        switch kind {
        case .primary:
            return SDColor.textPrimary
        case .hiVis:
            return SDColor.hiVis
        case .secondary:
            return SDColor.fill
        case .ghost, .danger:
            return Color.clear
        }
    }
}

#Preview {
    VStack(spacing: SDSpacing.medium) {
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
    .padding(SDSpacing.regular)
}
