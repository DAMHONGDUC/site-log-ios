import SwiftUI

public struct SDSectionHeader: View {
    let title: String
    let trailing: String?

    public init(title: String, trailing: String? = nil) {
        self.title = title
        self.trailing = trailing
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(SDFont.section)
                .foregroundStyle(SDColor.textPrimary)

            Spacer()

            if let trailing {
                Text(trailing)
                    .font(SDFont.subhead)
                    .foregroundStyle(SDColor.textSecondary)
            }
        }
        .padding(.horizontal, SDSpacing.regular)
    }
}

#Preview {
    SDSectionHeader(title: "Level 7", trailing: "3 open")
}
