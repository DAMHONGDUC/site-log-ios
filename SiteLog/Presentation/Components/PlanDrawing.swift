// Placeholder plan; the PDFKit viewer replaces it in F11

import DesignSystem
import SwiftUI

struct PlanDrawing: View {
    let pins: [FakePin]
    var onPinTap: (FakePin) -> Void = { _ in }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                DSColor.plan
                    .overlay {
                        Text("components.plan_drawing.floor_plan")
                            .foregroundStyle(DSColor.textTertiary)
                    }

                ForEach(pins) { pin in
                    PlanPinView(pin: pin)
                        .position(
                            x: proxy.size.width * pin.positionX,
                            y: proxy.size.height * pin.positionY
                        )
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
            .modifier(DSTextStyle.footnoteBold)
            .foregroundStyle(DSColor.onMedia)
            .frame(width: DSSpacing.spacing28, height: DSSpacing.spacing28)
            .background(color, in: Circle())
            .frame(width: DSSpacing.spacing44, height: DSSpacing.spacing44)
            .contentShape(Rectangle())
    }

    private var color: Color {
        switch pin.severity {
        case .critical:
            return DSColor.critical
        case .major:
            return DSColor.major
        case .minor:
            return DSColor.minor
        case .resolved:
            return DSColor.success
        case .waiting:
            return DSColor.waiting
        }
    }
}

#Preview {
    PlanDrawing(pins: FakeData.pins)
}
