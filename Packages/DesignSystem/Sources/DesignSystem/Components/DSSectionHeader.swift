import SwiftUI

public struct DSSectionHeader: View {
    let title: String
    let trailing: String?

    public init(title: String, trailing: String? = nil) {
        self.title = title
        self.trailing = trailing
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .modifier(DSTextStyle.section)
                .foregroundStyle(DSColor.textPrimary)

            Spacer()

            if let trailing {
                Text(trailing)
                    .modifier(DSTextStyle.subhead)
                    .foregroundStyle(DSColor.textSecondary)
            }
        }
        .padding(.horizontal, DSSpacing.spacing16)
    }
}

#Preview {
    DSSectionHeader(title: "Level 7", trailing: "3 open")
}
