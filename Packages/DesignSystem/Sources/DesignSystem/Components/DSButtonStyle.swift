import SwiftUI

// Button in the five looks used by the mockups.
// Usage: Button("Save") { ... }.buttonStyle(.ds(.primary))
//        Button("Retry") { ... }.buttonStyle(.ds(.secondary, small: true))
public struct DSButtonStyle: ButtonStyle {
    public enum Kind: CaseIterable, Sendable {
        // Graphite fill: the main action of a screen
        case primary
        // Yellow fill: capture only
        case hiVis
        // Light grey fill: second action
        case secondary
        // No fill: third action ("Continue offline")
        case ghost
        // Red text: destructive action
        case danger
    }

    let kind: Kind
    // Small = 34 pt capsule that hugs its text (row actions like "Pair", "Retry")
    let small: Bool

    public init(kind: Kind, small: Bool = false) {
        self.kind = kind
        self.small = small
    }

    public func makeBody(configuration: Configuration) -> some View {
        // A separate view, because only a View can read @Environment(\.isEnabled)
        DSButtonBody(kind: kind, small: small, label: configuration.label, isPressed: configuration.isPressed)
    }
}

// Lets you write .buttonStyle(.ds(.primary)) instead of .buttonStyle(DSButtonStyle(kind: .primary))
extension ButtonStyle where Self == DSButtonStyle {
    public static func ds(_ kind: DSButtonStyle.Kind, small: Bool = false) -> DSButtonStyle {
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
            .buttonStyle(.ds(.primary))
        Button("Capture") {}
            .buttonStyle(.ds(.hiVis))
        Button("Continue with email") {}
            .buttonStyle(.ds(.secondary))
        Button("Continue offline") {}
            .buttonStyle(.ds(.ghost))
        Button("Delete project") {}
            .buttonStyle(.ds(.danger))
        Button("Retry") {}
            .buttonStyle(.ds(.secondary, small: true))
        Button("Disabled") {}
            .buttonStyle(.ds(.primary))
            .disabled(true)
    }
    .padding(DSSpacing.regular)
}
