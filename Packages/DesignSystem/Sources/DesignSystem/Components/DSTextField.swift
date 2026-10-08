import SwiftUI

// Grey filled text field with an optional label above ("Name", "Site address").
public struct DSTextField: View {
    let label: String?
    let placeholder: String
    @Binding var text: String
    // true = grows to several lines (notes, footer)
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
        VStack(alignment: .leading, spacing: 6) {
            if let label {
                Text(label)
                    .font(DSFont.footnote)
                    .foregroundStyle(DSColor.textSecondary)
            }

            HStack(spacing: DSSpacing.small) {
                field

                if let trailingSystemImage {
                    Image(systemName: trailingSystemImage)
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, isMultiline ? 11 : 0)
            .frame(minHeight: isMultiline ? 72 : DSSize.fieldHeight, alignment: .topLeading)
            .background(DSColor.fill, in: RoundedRectangle(cornerRadius: DSRadius.field))
        }
    }

    @ViewBuilder private var field: some View {
        if isMultiline {
            TextField(placeholder, text: $text, axis: .vertical)
                .font(DSFont.body)
                .lineLimit(2...5)
        } else {
            TextField(placeholder, text: $text)
                .font(DSFont.body)
        }
    }
}

#Preview {
    @Previewable @State var name = "Riverside Tower B"
    @Previewable @State var note = ""

    VStack(spacing: DSSpacing.regular) {
        DSTextField("Name", text: $name)
        DSTextField("Note", placeholder: "e.g. finishing check", text: $note, isMultiline: true)
    }
    .padding()
}
