import SwiftUI

// Red count badge, e.g. on the Issues tab or a toolbar button.
public struct DSCountBadge: View {
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
            .background(DSColor.critical, in: Capsule())
    }
}

// Thin graphite progress bar ("37 of 82 rooms").
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

// Hi-vis dot that marks a walkthrough in progress.
public struct DSLiveDot: View {
    public init() {}

    public var body: some View {
        Circle()
            .fill(DSColor.hiVis)
            .frame(width: 10, height: 10)
            .overlay(Circle().stroke(DSColor.textPrimary, lineWidth: 1.5))
    }
}

// Outlined file-type tag ("PDF").
public struct DSFileTag: View {
    let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(DSColor.textSecondary)
            .padding(.horizontal, 5)
            .frame(height: 20)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(DSColor.textSecondary, lineWidth: 1))
    }
}

// Radio mark for single-choice lists (re-check outcome, Lock after).
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
                    .font(.system(size: 11, weight: .bold))
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
    VStack(spacing: DSSpacing.regular) {
        DSCountBadge(count: 14)
        DSProgressBar(value: 37.0 / 82.0)
        DSLiveDot()
        DSFileTag(text: "PDF")
        HStack {
            DSRadioMark(isOn: true)
            DSRadioMark(isOn: false)
        }
    }
    .padding()
}
