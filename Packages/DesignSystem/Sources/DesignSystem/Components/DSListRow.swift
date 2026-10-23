import SwiftUI

public struct DSListRow<Leading: View, Trailing: View>: View {
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
        HStack(spacing: DSSpacing.spacing12) {
            leading

            VStack(alignment: .leading, spacing: DSSpacing.spacing1) {
                Text(title)
                    .modifier(DSTextStyle.body)
                    .foregroundStyle(DSColor.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .modifier(DSTextStyle.subhead)
                        .foregroundStyle(DSColor.textSecondary)
                }
            }

            Spacer(minLength: DSSpacing.spacing8)

            trailing

            if showsChevron {
                Image(systemName: "chevron.right")
                    .modifier(DSTextStyle.footnoteSemibold)
                    .foregroundStyle(DSColor.textTertiary)
            }
        }
        .frame(minHeight: DSSpacing.spacing52)
        .padding(.horizontal, DSSpacing.spacing16)
        // Whole row is tappable
        .contentShape(Rectangle())
    }
}

extension DSListRow where Leading == EmptyView, Trailing == DSRowValue {
    public init(
        title: String,
        subtitle: String? = nil,
        value: String? = nil,
        showsChevron: Bool = false
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            showsChevron: showsChevron,
            leading: { EmptyView() },
            trailing: { DSRowValue(text: value) }
        )
    }
}

extension DSListRow where Trailing == DSRowValue {
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
            trailing: { DSRowValue(text: value) }
        )
    }
}

public struct DSRowValue: View {
    let text: String?

    public init(text: String?) {
        self.text = text
    }

    public var body: some View {
        if let text {
            Text(text)
                .modifier(DSTextStyle.body)
                .foregroundStyle(DSColor.textSecondary)
        }
    }
}

public struct DSDivider: View {
    let inset: CGFloat

    public init(inset: CGFloat = DSSpacing.spacing16) {
        self.inset = inset
    }

    public var body: some View {
        Rectangle()
            .fill(DSColor.hairline)
            .frame(height: 0.5)
            .padding(.leading, inset)
    }
}

#Preview {
    VStack(spacing: DSSpacing.spacing0) {
        DSListRow(
            title: "Riverside Tower B",
            subtitle: "District 7 · 14 open issues",
            showsChevron: true
        )
        DSDivider()
        DSListRow(title: "Lock after", value: "5 minutes", showsChevron: true)
        DSDivider()
        DSListRow(title: "Living room")
    }
}
