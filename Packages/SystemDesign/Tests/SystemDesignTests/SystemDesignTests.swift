import Testing
import UIKit
@testable import SystemDesign

struct SystemDesignTests {
    @Test func hexColourIsDecoded() {
        let color = UIColor(hex: 0xFFD400)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        #expect(red == 1)
        #expect(green == CGFloat(0xD4) / 255)
        #expect(blue == 0)
    }
}