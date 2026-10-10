import SwiftUI

// Shapes keep severity readable without colour
public struct SDStatusMarker: View {
    public enum Kind: CaseIterable, Sendable {
        case critical
        case major
        case minor
        case resolved
        // Never red
        case waiting
    }

    let kind: Kind
    let text: String
    let isLate: Bool

    public init(kind: Kind, text: String = "", isLate: Bool = false) {
        self.kind = kind
        self.text = text
        self.isLate = isLate
    }

    public var body: some View {
        HStack(spacing: 6) {
            shape
                .frame(width: 9, height: 9)

            if !text.isEmpty {
                Text(text)
                    .font(SDFont.footnote)
                    .foregroundStyle(textColor)
            }
        }
    }

    @ViewBuilder private var shape: some View {
        switch kind {
        case .critical:
            RoundedRectangle(cornerRadius: 1)
                .fill(SDColor.critical)
        case .major:
            SDTriangle()
                .fill(SDColor.major)
        case .minor:
            Circle()
                .strokeBorder(SDColor.minor, lineWidth: 2)
        case .resolved:
            Circle()
                .fill(SDColor.success)
        case .waiting:
            Circle()
                .strokeBorder(SDColor.waiting, style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
        }
    }

    private var textColor: Color {
        if isLate {
            return SDColor.critical
        }
        switch kind {
        case .resolved, .waiting:
            return SDColor.textSecondary
        case .critical, .major, .minor:
            return SDColor.textPrimary
        }
    }
}

public struct SDTriangle: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(alignment: .leading, spacing: SDSpacing.small) {
        SDStatusMarker(kind: .critical, text: "Critical")
        SDStatusMarker(kind: .major, text: "Major")
        SDStatusMarker(kind: .minor, text: "Minor")
        SDStatusMarker(kind: .resolved, text: "Resolved")
        SDStatusMarker(kind: .waiting, text: "Waiting")
        SDStatusMarker(kind: .critical, text: "Failed", isLate: true)
    }
}
