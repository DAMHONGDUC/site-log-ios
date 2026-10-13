import SwiftUI

// Every component on one screen: used by previews.
public struct DSGallery: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.regular) {
            DSSectionHeader(title: "Level 7", trailing: "3 open")

            VStack(spacing: 0) {
                DSListRow(
                    title: "Riverside Tower B",
                    subtitle: "District 7 · 14 open issues",
                    showsChevron: true
                )
                DSListRow(title: "Lock after", value: "5 minutes", showsChevron: true)
            }

            HStack(spacing: DSSpacing.small) {
                DSChip(title: "All", isSelected: true, action: {})
                DSChip(title: "Has issues", isSelected: false, action: {})
                DSCountBadge(count: 2)
            }
            .padding(.horizontal, DSSpacing.regular)

            HStack(spacing: DSSpacing.regular) {
                ForEach(DSStatusMarker.Kind.allCases, id: \.self) { kind in
                    DSStatusMarker(kind: kind, text: String(describing: kind).capitalized)
                }
            }
            .padding(.horizontal, DSSpacing.regular)

            VStack(spacing: DSSpacing.small) {
                Button("Primary") {}
                    .buttonStyle(.sd(.primary))
                Button("Capture") {}
                    .buttonStyle(.sd(.hiVis))
                Button("Secondary") {}
                    .buttonStyle(.sd(.secondary))
                Button("Ghost") {}
                    .buttonStyle(.sd(.ghost))
                Button("Danger") {}
                    .buttonStyle(.sd(.danger))
            }
            .padding(.horizontal, DSSpacing.regular)

            DSEmptyState(
                systemImage: "folder",
                title: "No projects yet",
                message: "Create a project to start."
            )
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, DSSpacing.regular)
        // Fill the whole screen, including behind the status bar
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DSColor.canvas.ignoresSafeArea())
    }
}

#Preview("Light") {
    DSGallery()
}

#Preview("Dark") {
    DSGallery()
        .preferredColorScheme(.dark)
}
