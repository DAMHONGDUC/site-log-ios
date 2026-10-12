import SwiftUI

public struct SDListRow<Leading: View, Trailing: View>: View {
    let title: String
    let subtitle: String?
    let showsChevron: Bool
    let leading: Leading
    let trailing: Trailing

    public init(
        title: String,
        subtitle: String? = nil,
        showsChevron: Bool = false,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showsChevron = showsChevron
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: SDSpacing.medium) {
            leading

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(SDFont.body)
                    .foregroundStyle(SDColor.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(SDFont.subhead)
                        .foregroundStyle(SDColor.textSecondary)
                }
            }

            Spacer(minLength: SDSpacing.small)

            trailing

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(SDFont.footnote.weight(.semibold))
                    .foregroundStyle(SDColor.textTertiary)
            }
        }
        .frame(minHeight: SDSize.rowMinHeight)
        .padding(.horizontal, SDSpacing.regular)
        // Whole row is tappable
        .contentShape(Rectangle())
    }
}

extension SDListRow where Leading == EmptyView, Trailing == SDRowValue {
    public init(title: String, subtitle: String? = nil, value: String? = nil, showsChevron: Bool = false) {
        self.init(
            title: title,
            subtitle: subtitle,
            showsChevron: showsChevron,
            leading: { EmptyView() },
            trailing: { SDRowValue(text: value) }
        )
    }
}

extension SDListRow where Trailing == SDRowValue {
    public init(
        title: String,
        subtitle: String? = nil,
        value: String? = nil,
        showsChevron: Bool = false,
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            showsChevron: showsChevron,
            leading: leading,
            trailing: { SDRowValue(text: value) }
        )
    }
}

public struct SDRowValue: View {
    let text: String?

    public init(text: String?) {
        self.text = text
    }

    public var body: some View {
        if let text {
            Text(text)
                .font(SDFont.body)
                .foregroundStyle(SDColor.textSecondary)
        }
    }
}

public struct SDDivider: View {
    let inset: CGFloat

    public init(inset: CGFloat = SDSpacing.regular) {
        self.inset = inset
    }

    public var body: some View {
        Rectangle()
            .fill(SDColor.hairline)
            .frame(height: 0.5)
            .padding(.leading, inset)
    }
}

#Preview {
    VStack(spacing: 0) {
        SDListRow(title: "Riverside Tower B", subtitle: "District 7 · 14 open issues", showsChevron: true)
        SDDivider()
        SDListRow(title: "Lock after", value: "5 minutes", showsChevron: true)
        SDDivider()
        SDListRow(title: "Living room")
    }
}
