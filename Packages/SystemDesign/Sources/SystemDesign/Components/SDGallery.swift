import SwiftUI

// Every component on one screen: used by previews.
public struct SDGallery: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.regular) {
            SDSectionHeader(title: "Level 7", trailing: "3 open")

            VStack(spacing: 0) {
                SDListRow(
                    title: "Riverside Tower B", subtitle: "District 7 · 14 open issues",
                    showsChevron: true)
                SDListRow(title: "Lock after", value: "5 minutes", showsChevron: true)
            }

            HStack(spacing: SDSpacing.small) {
                SDChip(title: "All", isSelected: true, action: {})
                SDChip(title: "Has issues", isSelected: false, action: {})
                SDCountBadge(count: 2)
            }
            .padding(.horizontal, SDSpacing.regular)

            HStack(spacing: SDSpacing.regular) {
                ForEach(SDStatusMarker.Kind.allCases, id: \.self) { kind in
                    SDStatusMarker(kind: kind, text: String(describing: kind).capitalized)
                }
            }
            .padding(.horizontal, SDSpacing.regular)

            VStack(spacing: SDSpacing.small) {
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
            .padding(.horizontal, SDSpacing.regular)

            SDEmptyState(
                systemImage: "folder", title: "No projects yet",
                message: "Create a project to start."
            )
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, SDSpacing.regular)
        // Fill the whole screen, including behind the status bar
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SDColor.canvas.ignoresSafeArea())
    }
}

#Preview("Light") {
    SDGallery()
}

#Preview("Dark") {
    SDGallery()
        .preferredColorScheme(.dark)
}