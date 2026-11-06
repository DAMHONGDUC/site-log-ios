// R4 · Signatures

import DesignSystem
import Inject
import SwiftUI

struct SignaturePadScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator
    @Environment(\.dismiss) private var dismiss

    @State private var party = "Contractor"
    @State private var nameAndRole = "Tran Minh, site manager"
    @State private var strokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                Picker("reports.signature_pad.party", selection: $party) {
                    Text(verbatim: "Hanh (supervisor) ✓").tag("Supervisor")
                    Text("reports.signature_pad.contractor").tag("Contractor")
                }
                .pickerStyle(.segmented)

                DSTextField(
                    String(localized: "reports.signature_pad.name_and_role"),
                    text: $nameAndRole
                )

                signatureBox

                Text(
                    "reports.signature_pad.signature_disclaimer"
                )
                .modifier(DSTextStyle.footnote)
                .foregroundStyle(DSColor.textSecondary)
            }
            .padding(DSSpacing.spacing16)
        }
        // Drawing must not scroll the page
        .scrollDisabled(true)
        .background(DSColor.canvas)
        .navigationTitle("reports.signature_pad.sign")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            Button("reports.signature_pad.done") {
                coordinator.push(ReportsRoute.pdfPreview)
            }
            .buttonStyle(.sd(.primary))
        }
        .enableInjection()
    }

    private var signatureBox: some View {
        RoundedRectangle(cornerRadius: DSSpacing.spacing12)
            .fill(DSColor.fill)
            .frame(height: DSSpacing.spacing240)
            .overlay {
                Canvas { context, size in
                    var line = Path()
                    line.move(
                        to: CGPoint(x: DSSpacing.spacing28, y: size.height - DSSpacing.spacing48)
                    )
                    line.addLine(
                        to: CGPoint(
                            x: size.width - DSSpacing.spacing28,
                            y: size.height - DSSpacing.spacing48
                        )
                    )
                    context.stroke(
                        line,
                        with: .color(DSColor.lineStrong),
                        lineWidth: DSSpacing.spacing1
                    )

                    for stroke in strokes + [currentStroke] {
                        var path = Path()
                        path.addLines(stroke)
                        context.stroke(
                            path,
                            with: .color(DSColor.textPrimary),
                            style: StrokeStyle(lineWidth: DSSpacing.spacing2Point4, lineCap: .round)
                        )
                    }
                }
            }
            .overlay(alignment: .bottom) {
                HStack {
                    Text("reports.signature_pad.sign_above_the_line")
                        .modifier(DSTextStyle.footnote)
                        .foregroundStyle(DSColor.textSecondary)
                    Spacer()
                    Button("reports.signature_pad.clear") {
                        strokes = []
                    }
                    .modifier(DSTextStyle.subheadSemibold)
                    .underline()
                    .foregroundStyle(DSColor.textPrimary)
                }
                .padding(.horizontal, DSSpacing.spacing16)
                .padding(.bottom)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        currentStroke.append(value.location)
                    }
                    .onEnded { _ in
                        strokes.append(currentStroke)
                        currentStroke = []
                    }
            )
    }
}

#Preview {
    NavigationStack {
        SignaturePadScreen()
    }
}
