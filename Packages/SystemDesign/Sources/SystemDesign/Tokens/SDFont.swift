import SwiftUI

// Values from TYPE_TOKENS; all Dynamic Type styles
public enum SDFont {
    public static let largeTitle = Font.largeTitle.bold()
    public static let title = Font.title2.bold()
    public static let section = Font.title3.weight(.semibold)
    public static let headline = Font.headline
    public static let body = Font.body
    public static let subhead = Font.subheadline
    public static let footnote = Font.footnote
    public static let caption = Font.caption2.weight(.medium)
    // Only for real codes: hashes, file names, report IDs
    public static let code = Font.footnote.monospaced()
    public static let figure = Font.title.weight(.semibold).monospacedDigit()
}
