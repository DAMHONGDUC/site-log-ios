import SwiftUI

public struct DSTextField: View {
    let label: String?
    let placeholder: String
    @Binding var text: String
    let isMultiline: Bool
    let trailingSystemImage: String?

    public init(
        _ label: String? = nil,
        placeholder: String = "",
        text: Binding<String>,
        isMultiline: Bool = false,
        trailingSystemImage: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.isMultiline = isMultiline
        self.trailingSystemImage = trailingSystemImage
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing6) {
            if let label {
                Text(label)
                    .modifier(DSTextStyle.footnote)
                    .foregroundStyle(DSColor.textSecondary)
            }

            HStack(spacing: DSSpacing.spacing8) {
                field

                if let trailingSystemImage {
                    Image(systemName: trailingSystemImage)
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
            .padding(.horizontal, DSSpacing.spacing14)
            .padding(
                .vertical,
                isMultiline ? DSSpacing.spacing11 : DSSpacing.spacing0
            )
            .frame(
                minHeight: isMultiline
                    ? DSSpacing.spacing72 : DSSpacing.spacing46,
                alignment: .topLeading
            )
            .background(
                DSColor.fill,
                in: RoundedRectangle(cornerRadius: DSSpacing.spacing11)
            )
        }
    }

    @ViewBuilder private var field: some View {
        if isMultiline {
            TextField(placeholder, text: $text, axis: .vertical)
                .modifier(DSTextStyle.body)
                .lineLimit(2...5)
        } else {
            TextField(placeholder, text: $text)
                .modifier(DSTextStyle.body)
        }
    }
}

#Preview {
    @Previewable @State var name = "Riverside Tower B"
    @Previewable @State var note = ""

    VStack(spacing: DSSpacing.spacing16) {
        DSTextField("Name", text: $name)
        DSTextField("Note", placeholder: "e.g. finishing check", text: $note, isMultiline: true)
    }
    .padding(DSSpacing.spacing16)
}
