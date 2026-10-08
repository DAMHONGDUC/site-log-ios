import SwiftUI

// Shown when a list has nothing yet ("No projects yet").
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
        VStack(spacing: DSSpacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(DSColor.textTertiary)

            Text(title)
                .font(DSFont.headline)
                .foregroundStyle(DSColor.textPrimary)

            Text(message)
                .font(DSFont.subhead)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DSSpacing.large)
    }
}

#Preview {
    DSEmptyState(
        systemImage: "folder",
        title: "No projects yet",
        message: "Create a project to start your first walkthrough."
    )
}
