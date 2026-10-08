//
//  PlanDrawing.swift
//  SiteLog
//
//  Placeholder floor plan with tappable pins on top.
//  The real viewer (PDFKit + CATiledLayer) replaces the background in M4.
//

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
                        Text("Floor plan")
                            .foregroundStyle(DSColor.textTertiary)
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

// Numbered circle in the severity colour
struct PlanPinView: View {
    let pin: FakePin

    var body: some View {
        Text(String(pin.number))
            .font(DSFont.footnote.bold())
            .foregroundStyle(Color.white)
            .frame(width: 28, height: 28)
            .background(color, in: Circle())
            .frame(width: DSSize.minTapTarget, height: DSSize.minTapTarget)
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
