import SwiftUI

// Type tokens from TYPE_TOKENS in the mockups.
// All are Dynamic Type text styles, so they grow with the user's text size setting.
public enum DSFont {
    // Top-level screen titles
    public static let largeTitle = Font.largeTitle.bold()
    // Detail titles, summary headline
    public static let title = Font.title2.bold()
    // Section headers on plain lists
    public static let section = Font.title3.weight(.semibold)
    // Nav title, buttons, emphasised rows
    public static let headline = Font.headline
    // List row titles, text fields
    public static let body = Font.body
    // Row subtitles, descriptions
    public static let subhead = Font.subheadline
    // Field labels, footers, severity text
    public static let footnote = Font.footnote
    // Tab bar labels
    public static let caption = Font.caption2.weight(.medium)
    // Only real codes: hashes, file names, report IDs
    public static let code = Font.footnote.monospaced()
    // Big progress figures ("187 of 243")
    public static let figure = Font.title.weight(.semibold).monospacedDigit()
}
