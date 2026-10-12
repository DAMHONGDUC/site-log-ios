import SwiftUI
import UIKit

// Values from COLOR_TOKENS in docs/design/mockups/index.html
public enum SDColor {
    public static let canvas = dynamic(light: 0xFFFFFF, dark: 0x0F1011)
    public static let raised = dynamic(light: 0xFFFFFF, dark: 0x18191B)
    public static let fill = dynamic(light: 0xF3F2EF, dark: 0x232427)
    public static let plan = dynamic(light: 0xFBFAF7, dark: 0x1B1C1E)

    public static let hairline = dynamic(light: 0xE8E5E0, dark: 0x2C2D31)
    public static let lineStrong = dynamic(light: 0xCFCAC1, dark: 0x3F4045)

    public static let textPrimary = dynamic(light: 0x16181B, dark: 0xF2F0EC)
    public static let textSecondary = dynamic(light: 0x63676E, dark: 0xA4A7AD)
    public static let textTertiary = dynamic(light: 0xA0A3A9, dark: 0x6E7278)
    public static let onPrimary = dynamic(light: 0xFFFFFF, dark: 0x16181B)

    // Hi-vis: app mark, capture button and live dot only
    public static let hiVis = dynamic(light: 0xFFD400, dark: 0xFFD400)
    public static let onHiVis = dynamic(light: 0x1B1700, dark: 0x1B1700)

    public static let critical = dynamic(light: 0xD8342A, dark: 0xFF5B4F)
    public static let major = dynamic(light: 0xDD7A06, dark: 0xFFA43D)
    public static let minor = dynamic(light: 0x3E6FA8, dark: 0x80A9DC)
    public static let success = dynamic(light: 0x1D8454, dark: 0x43C287)
    // Never red
    public static let waiting = dynamic(light: 0x7E838B, dark: 0x8E939B)

    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        let lightColor = UIColor(hex: light)
        let darkColor = UIColor(hex: dark)

        let uiColor = UIColor { traits in
            if traits.userInterfaceStyle == .dark {
                return darkColor
            } else {
                return lightColor
            }
        }

        return Color(uiColor: uiColor)
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
