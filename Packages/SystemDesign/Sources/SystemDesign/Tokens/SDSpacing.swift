import CoreGraphics

public enum SDSpacing {
    public static let tiny: CGFloat = 4
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 12
    public static let regular: CGFloat = 16
    public static let large: CGFloat = 24
    public static let xLarge: CGFloat = 32
}

public enum SDRadius {
    public static let small: CGFloat = 5
    public static let medium: CGFloat = 9
    public static let field: CGFloat = 11
    public static let button: CGFloat = 13
    public static let large: CGFloat = 16
}

public enum SDSize {
    public static let buttonHeight: CGFloat = 50
    public static let smallButtonHeight: CGFloat = 34
    public static let fieldHeight: CGFloat = 46
    public static let rowMinHeight: CGFloat = 52
    // Apple minimum; gloves need at least this
    public static let minTapTarget: CGFloat = 44
    public static let captureButton: CGFloat = 68
}
