import SwiftUI

public struct SDEmptyState: View {
    let systemImage: String
    let title: String
    let message: String

    public init(systemImage: String, title: String, message: String) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: SDSpacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(SDColor.textTertiary)

            Text(title)
                .font(SDFont.headline)
                .foregroundStyle(SDColor.textPrimary)

            Text(message)
                .font(SDFont.subhead)
                .foregroundStyle(SDColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(SDSpacing.large)
    }
}

#Preview {
    SDEmptyState(
        systemImage: "folder",
        title: "No projects yet",
        message: "Create a project to start your first walkthrough."
    )
}
