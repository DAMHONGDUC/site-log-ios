import SwiftUI

public struct SDCountBadge: View {
    let count: Int

    public init(count: Int) {
        self.count = count
    }

    public var body: some View {
        Text(String(count))
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 5)
            .frame(minWidth: 18, minHeight: 18)
            .background(SDColor.critical, in: Capsule())
    }
}

public struct SDProgressBar: View {
    // 0...1
    let value: Double

    public init(value: Double) {
        self.value = value
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(SDColor.fill)
                Capsule()
                    .fill(SDColor.textPrimary)
                    .frame(width: proxy.size.width * min(max(value, 0), 1))
            }
        }
        .frame(height: 4)
    }
}

public struct SDLiveDot: View {
    public init() {}

    public var body: some View {
        Circle()
            .fill(SDColor.hiVis)
            .frame(width: 10, height: 10)
            .overlay(Circle().stroke(SDColor.textPrimary, lineWidth: 1.5))
    }
}

public struct SDFileTag: View {
    let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(SDColor.textSecondary)
            .padding(.horizontal, 5)
            .frame(height: 20)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(SDColor.textSecondary, lineWidth: 1))
    }
}

public struct SDRadioMark: View {
    let isOn: Bool

    public init(isOn: Bool) {
        self.isOn = isOn
    }

    public var body: some View {
        ZStack {
            if isOn {
                Circle()
                    .fill(SDColor.textPrimary)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(SDColor.onPrimary)
            } else {
                Circle()
                    .strokeBorder(SDColor.lineStrong, lineWidth: 1.5)
            }
        }
        .frame(width: 22, height: 22)
    }
}

#Preview {
    VStack(spacing: SDSpacing.regular) {
        SDCountBadge(count: 14)
        SDProgressBar(value: 37.0 / 82.0)
        SDLiveDot()
        SDFileTag(text: "PDF")
        HStack {
            SDRadioMark(isOn: true)
            SDRadioMark(isOn: false)
        }
    }
    .padding()
}
