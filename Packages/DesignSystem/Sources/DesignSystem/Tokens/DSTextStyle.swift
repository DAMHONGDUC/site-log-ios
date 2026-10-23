import SwiftUI

/// The font family used by a shared text style.
public enum AppFontFamily: Sendable {
    case sans
    case monospaced

    fileprivate var design: Font.Design {
        switch self {
        case .sans: .default
        case .monospaced: .monospaced
        }
    }
}

/// Fixed text styles shared by app screens and DesignSystem components.
@MainActor
public struct DSTextStyle: ViewModifier {
    public let fontFamily: AppFontFamily
    public let fontSize: CGFloat
    public let fontWeight: Font.Weight
    public let lineHeight: CGFloat

    public func body(content: Content) -> some View {
        content
            .font(.system(size: fontSize, weight: fontWeight, design: fontFamily.design))
            .lineSpacing(max(0, lineHeight - fontSize))
    }

    public static let largeTitle = style(.sans, 34, .bold, 41)
    public static let title = style(.sans, 24, .bold, 30)
    public static let pageTitle = style(.sans, 28, .bold, 34)
    public static let section = style(.sans, 20, .semibold, 25)
    public static let headline = style(.sans, 17, .semibold, 22)
    public static let body = style(.sans, 17, .regular, 22)
    public static let bodyMedium = style(.sans, 17, .medium, 22)
    public static let subhead = style(.sans, 15, .regular, 20)
    public static let subheadSemibold = style(.sans, 15, .semibold, 20)
    public static let footnote = style(.sans, 13, .regular, 18)
    public static let footnoteSemibold = style(.sans, 13, .semibold, 18)
    public static let footnoteBold = style(.sans, 13, .bold, 18)
    public static let caption = style(.sans, 10, .medium, 12)
    public static let badge = style(.sans, 10, .semibold, 12)
    public static let code = style(.monospaced, 13, .regular, 18)
    public static let subheadMonospaced = style(.monospaced, 15, .regular, 20)
    public static let figure = style(.sans, 28, .semibold, 34)
    public static let iconSmall = style(.sans, 11, .bold, 13)
    public static let iconMedium = style(.sans, 20, .regular, 24)
    public static let iconLarge = style(.sans, 40, .regular, 48)

    private static func style(
        _ family: AppFontFamily,
        _ size: CGFloat,
        _ weight: Font.Weight,
        _ lineHeight: CGFloat
    ) -> DSTextStyle {
        DSTextStyle(
            fontFamily: family,
            fontSize: size,
            fontWeight: weight,
            lineHeight: lineHeight
        )
    }
}
