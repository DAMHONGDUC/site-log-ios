import CoreGraphics

// Spacing scale (points). Use these instead of typing numbers in views.
public enum DSSpacing {
    public static let tiny: CGFloat = 4
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 12
    // Screen side margin, row padding
    public static let regular: CGFloat = 16
    public static let large: CGFloat = 24
    public static let xLarge: CGFloat = 32
}

// Corner radius scale (points).
public enum DSRadius {
    // Small tags
    public static let small: CGFloat = 5
    // Thumbnails, segmented control track
    public static let medium: CGFloat = 9
    // Text fields
    public static let field: CGFloat = 11
    // Full-width buttons
    public static let button: CGFloat = 13
    // Sheets, panels
    public static let large: CGFloat = 16
}

// Fixed sizes from the iOS metrics in docs/design/00-design-plan.md.
public enum DSSize {
    public static let buttonHeight: CGFloat = 50
    public static let smallButtonHeight: CGFloat = 34
    public static let fieldHeight: CGFloat = 46
    public static let rowMinHeight: CGFloat = 52
    // Apple's minimum touch target; gloves need at least this
    public static let minTapTarget: CGFloat = 44
    // Yellow capture button in the bottom toolbar
    public static let captureButton: CGFloat = 68
}
