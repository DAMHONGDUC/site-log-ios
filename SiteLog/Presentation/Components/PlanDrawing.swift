// Placeholder plan; the PDFKit viewer replaces it in F08

import SystemDesign
import SwiftUI

struct PlanDrawing: View {
    let pins: [FakePin]
    var onPinTap: (FakePin) -> Void = { _ in }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                SDColor.plan
                    .overlay {
                        Text("Floor plan")
                            .foregroundStyle(SDColor.textTertiary)
                    }

                ForEach(pins) { pin in
                    PlanPinView(pin: pin)
                        .position(x: proxy.size.width * pin.positionX, y: proxy.size.height * pin.positionY)
                        .onTapGesture {
                            onPinTap(pin)
                        }
                }
            }
        }
    }
}

struct PlanPinView: View {
    let pin: FakePin

    var body: some View {
        Text(String(pin.number))
            .font(SDFont.footnote.bold())
            .foregroundStyle(Color.white)
            .frame(width: 28, height: 28)
            .background(color, in: Circle())
            .frame(width: SDSize.minTapTarget, height: SDSize.minTapTarget)
            .contentShape(Rectangle())
    }

    private var color: Color {
        switch pin.severity {
        case .critical:
            return SDColor.critical
        case .major:
            return SDColor.major
        case .minor:
            return SDColor.minor
        case .resolved:
            return SDColor.success
        case .waiting:
            return SDColor.waiting
        }
    }
}

#Preview {
    PlanDrawing(pins: FakeData.pins)
}
