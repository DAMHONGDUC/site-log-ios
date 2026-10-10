import SwiftUI

public struct SDTextField: View {
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
        VStack(alignment: .leading, spacing: 6) {
            if let label {
                Text(label)
                    .font(SDFont.footnote)
                    .foregroundStyle(SDColor.textSecondary)
            }

            HStack(spacing: SDSpacing.small) {
                field

                if let trailingSystemImage {
                    Image(systemName: trailingSystemImage)
                        .foregroundStyle(SDColor.textSecondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, isMultiline ? 11 : 0)
            .frame(minHeight: isMultiline ? 72 : SDSize.fieldHeight, alignment: .topLeading)
            .background(SDColor.fill, in: RoundedRectangle(cornerRadius: SDRadius.field))
        }
    }

    @ViewBuilder private var field: some View {
        if isMultiline {
            TextField(placeholder, text: $text, axis: .vertical)
                .font(SDFont.body)
                .lineLimit(2...5)
        } else {
            TextField(placeholder, text: $text)
                .font(SDFont.body)
        }
    }
}

#Preview {
    @Previewable @State var name = "Riverside Tower B"
    @Previewable @State var note = ""

    VStack(spacing: SDSpacing.regular) {
        SDTextField("Name", text: $name)
        SDTextField("Note", placeholder: "e.g. finishing check", text: $note, isMultiline: true)
    }
    .padding()
}
