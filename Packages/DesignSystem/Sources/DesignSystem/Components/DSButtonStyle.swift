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
                .modifier(DSTextStyle.subheadSemibold)
                .foregroundStyle(textColor)
                .padding(.horizontal, DSSpacing.spacing14)
                .frame(height: DSSpacing.spacing34)
                .background(background, in: Capsule())
                .opacity(opacity)
        } else {
            label
                .modifier(font)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: DSSpacing.spacing50)
                .background(
                    background,
                    in: RoundedRectangle(cornerRadius: DSSpacing.spacing13)
                )
                .contentShape(RoundedRectangle(cornerRadius: DSSpacing.spacing13))
                .opacity(opacity)
        }
    }

    private var font: DSTextStyle {
        if kind == .ghost {
            return DSTextStyle.bodyMedium
        }
        return DSTextStyle.headline
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
            return DSColor.clear
        }
    }
}

#Preview {
    VStack(spacing: DSSpacing.spacing12) {
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
    .padding(DSSpacing.spacing16)
}
