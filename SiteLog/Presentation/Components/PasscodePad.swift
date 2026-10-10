import SystemDesign
import SwiftUI

struct PasscodeDots: View {
    let filled: Int
    var length: Int = 6

    var body: some View {
        HStack {
            ForEach(0..<length, id: \.self) { index in
                Image(systemName: index < filled ? "circle.fill" : "circle")
            }
        }
    }
}

struct PasscodeNumberPad: View {
    @Binding var code: String
    var length: Int = 6

    private let keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "delete"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: SDSpacing.regular) {
            ForEach(keys, id: \.self) { key in
                keyView(key)
            }
        }
        .padding(.horizontal, SDSpacing.xLarge)
    }

    @ViewBuilder private func keyView(_ key: String) -> some View {
        if key.isEmpty {
            Color.clear
        } else if key == "delete" {
            Button("Delete", systemImage: "delete.left") {
                if !code.isEmpty {
                    code.removeLast()
                }
            }
            .labelStyle(.iconOnly)
        } else {
            Button(key) {
                if code.count < length {
                    code.append(key)
                }
            }
            .font(SDFont.title)
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    @Previewable @State var code = "12"

    VStack {
        PasscodeDots(filled: code.count)
        PasscodeNumberPad(code: $code)
    }
}
