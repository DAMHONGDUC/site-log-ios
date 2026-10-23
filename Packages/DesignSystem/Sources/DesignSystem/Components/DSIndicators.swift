import SwiftUI

public struct DSCountBadge: View {
    let count: Int

    public init(count: Int) {
        self.count = count
    }

    public var body: some View {
        Text(String(count))
            .modifier(DSTextStyle.badge)
            .foregroundStyle(DSColor.onMedia)
            .padding(.horizontal, DSSpacing.spacing5)
            .frame(minWidth: 18, minHeight: 18)
            .background(DSColor.critical, in: Capsule())
    }
}

public struct DSProgressBar: View {
    // 0...1
    let value: Double

    public init(value: Double) {
        self.value = value
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DSColor.fill)
                Capsule()
                    .fill(DSColor.textPrimary)
                    .frame(width: proxy.size.width * min(max(value, 0), 1))
            }
        }
        .frame(height: 4)
    }
}

public struct DSLiveDot: View {
    public init() {}

    public var body: some View {
        Circle()
            .fill(DSColor.hiVis)
            .frame(width: 10, height: 10)
            .overlay(Circle().stroke(DSColor.textPrimary, lineWidth: 1.5))
    }
}

public struct DSFileTag: View {
    let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .modifier(DSTextStyle.badge)
            .foregroundStyle(DSColor.textSecondary)
            .padding(.horizontal, DSSpacing.spacing5)
            .frame(height: 20)
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.spacing4).stroke(
                    DSColor.textSecondary,
                    lineWidth: 1
                )
            )
    }
}

public struct DSRadioMark: View {
    let isOn: Bool

    public init(isOn: Bool) {
        self.isOn = isOn
    }

    public var body: some View {
        ZStack {
            if isOn {
                Circle()
                    .fill(DSColor.textPrimary)
                Image(systemName: "checkmark")
                    .modifier(DSTextStyle.iconSmall)
                    .foregroundStyle(DSColor.onPrimary)
            } else {
                Circle()
                    .strokeBorder(DSColor.lineStrong, lineWidth: 1.5)
            }
        }
        .frame(width: 22, height: 22)
    }
}

#Preview {
    VStack(spacing: DSSpacing.spacing16) {
        DSCountBadge(count: 14)
        DSProgressBar(value: 37.0 / 82.0)
        DSLiveDot()
        DSFileTag(text: "PDF")
        HStack {
            DSRadioMark(isOn: true)
            DSRadioMark(isOn: false)
        }
    }
    .padding(DSSpacing.spacing16)
}
