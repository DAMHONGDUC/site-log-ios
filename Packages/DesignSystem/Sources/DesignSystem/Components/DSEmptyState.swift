import SwiftUI

public struct DSEmptyState: View {
    let systemImage: String
    let title: String
    let message: String

    public init(systemImage: String, title: String, message: String) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: DSSpacing.spacing12) {
            Image(systemName: systemImage)
                .modifier(DSTextStyle.iconLarge)
                .foregroundStyle(DSColor.textTertiary)

            Text(title)
                .modifier(DSTextStyle.headline)
                .foregroundStyle(DSColor.textPrimary)

            Text(message)
                .modifier(DSTextStyle.subhead)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DSSpacing.spacing24)
    }
}

#Preview {
    DSEmptyState(
        systemImage: "folder",
        title: "No projects yet",
        message: "Create a project to start your first walkthrough."
    )
}
