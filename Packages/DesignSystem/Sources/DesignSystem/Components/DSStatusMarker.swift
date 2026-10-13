import SwiftUI

// Shapes keep severity readable without colour
public struct DSStatusMarker: View {
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
                    .font(DSFont.footnote)
                    .foregroundStyle(textColor)
            }
        }
    }

    @ViewBuilder private var shape: some View {
        switch kind {
        case .critical:
            RoundedRectangle(cornerRadius: 1)
                .fill(DSColor.critical)
        case .major:
            DSTriangle()
                .fill(DSColor.major)
        case .minor:
            Circle()
                .strokeBorder(DSColor.minor, lineWidth: 2)
        case .resolved:
            Circle()
                .fill(DSColor.success)
        case .waiting:
            Circle()
                .strokeBorder(DSColor.waiting, style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
        }
    }

    private var textColor: Color {
        if isLate {
            return DSColor.critical
        }
        switch kind {
        case .resolved, .waiting:
            return DSColor.textSecondary
        case .critical, .major, .minor:
            return DSColor.textPrimary
        }
    }
}

public struct DSTriangle: Shape {
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
    VStack(alignment: .leading, spacing: DSSpacing.small) {
        DSStatusMarker(kind: .critical, text: "Critical")
        DSStatusMarker(kind: .major, text: "Major")
        DSStatusMarker(kind: .minor, text: "Minor")
        DSStatusMarker(kind: .resolved, text: "Resolved")
        DSStatusMarker(kind: .waiting, text: "Waiting")
        DSStatusMarker(kind: .critical, text: "Failed", isLate: true)
    }
}
