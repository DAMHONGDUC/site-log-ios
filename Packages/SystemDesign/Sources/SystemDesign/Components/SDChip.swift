import SwiftUI

public struct SDChip: View {
    let title: String
    let systemImage: String?
    let isSelected: Bool
    let action: () -> Void

    public init(title: String, systemImage: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: SDSpacing.tiny) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(SDFont.subhead)
            .foregroundStyle(textColor)
            .padding(.horizontal, 13)
            .frame(height: 32)
            .background(backgroundColor, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var textColor: Color {
        if isSelected {
            return SDColor.onPrimary
        }
        return SDColor.textPrimary
    }

    private var backgroundColor: Color {
        if isSelected {
            return SDColor.textPrimary
        }
        return SDColor.fill
    }
}

#Preview {
    HStack(spacing: SDSpacing.small) {
        SDChip(title: "All", isSelected: true, action: {})
        SDChip(title: "Not checked", isSelected: false, action: {})
        SDChip(title: "Sunny", systemImage: "sun.max", isSelected: false, action: {})
    }
}
