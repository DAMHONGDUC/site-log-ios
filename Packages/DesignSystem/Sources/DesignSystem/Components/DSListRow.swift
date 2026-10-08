import SwiftUI

// One row of a plain iOS list: optional leading view, title, optional subtitle,
// optional trailing view, optional chevron.
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
        HStack(spacing: DSSpacing.medium) {
            leading

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(DSFont.body)
                    .foregroundStyle(DSColor.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(DSFont.subhead)
                        .foregroundStyle(DSColor.textSecondary)
                }
            }

            Spacer(minLength: DSSpacing.small)

            trailing

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(DSFont.footnote.weight(.semibold))
                    .foregroundStyle(DSColor.textTertiary)
            }
        }
        .frame(minHeight: DSSize.rowMinHeight)
        .padding(.horizontal, DSSpacing.regular)
        // Makes the empty space tappable too
        .contentShape(Rectangle())
    }
}

// Row with a plain grey value on the right instead of a custom view
extension DSListRow where Leading == EmptyView, Trailing == DSRowValue {
    public init(title: String, subtitle: String? = nil, value: String? = nil, showsChevron: Bool = false) {
        self.init(
            title: title,
            subtitle: subtitle,
            showsChevron: showsChevron,
            leading: { EmptyView() },
            trailing: { DSRowValue(text: value) }
        )
    }
}

// Row with a leading view and an optional grey value
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

// Grey value text on the right of a row ("5 minutes")
public struct DSRowValue: View {
    let text: String?

    public init(text: String?) {
        self.text = text
    }

    public var body: some View {
        if let text {
            Text(text)
                .font(DSFont.body)
                .foregroundStyle(DSColor.textSecondary)
        }
    }
}

// Hairline between rows, inset from the left like iOS lists
public struct DSDivider: View {
    let inset: CGFloat

    public init(inset: CGFloat = DSSpacing.regular) {
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
    VStack(spacing: 0) {
        DSListRow(title: "Riverside Tower B", subtitle: "District 7 · 14 open issues", showsChevron: true)
        DSDivider()
        DSListRow(title: "Lock after", value: "5 minutes", showsChevron: true)
        DSDivider()
        DSListRow(title: "Living room")
    }
}
