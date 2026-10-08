import SwiftUI

public struct DSChip: View {
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
            HStack(spacing: DSSpacing.tiny) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(DSFont.subhead)
            .foregroundStyle(textColor)
            .padding(.horizontal, 13)
            .frame(height: 32)
            .background(backgroundColor, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var textColor: Color {
        if isSelected {
            return DSColor.onPrimary
        }
        return DSColor.textPrimary
    }

    private var backgroundColor: Color {
        if isSelected {
            return DSColor.textPrimary
        }
        return DSColor.fill
    }
}

#Preview {
    HStack(spacing: DSSpacing.small) {
        DSChip(title: "All", isSelected: true, action: {})
        DSChip(title: "Not checked", isSelected: false, action: {})
        DSChip(title: "Sunny", systemImage: "sun.max", isSelected: false, action: {})
    }
}
