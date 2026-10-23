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
                Picker("reports.signaturePad.party", selection: $party) {
                    Text("reports.signaturePad.hanhSupervisor").tag("Supervisor")
                    Text("reports.signaturePad.contractor").tag("Contractor")
                }
                .pickerStyle(.segmented)

                DSTextField(
                    String(localized: "reports.signaturePad.nameAndRole"),
                    text: $nameAndRole
                )

                signatureBox

                Text(
                    "reports.signaturePad.thisIsAHandwrittenSignatureForInternalSignOffNotACertifiedDigitalSignature"
                )
                .modifier(DSTextStyle.footnote)
                .foregroundStyle(DSColor.textSecondary)
            }
            .padding(DSSpacing.spacing16)
        }
        // Drawing must not scroll the page
        .scrollDisabled(true)
        .background(DSColor.canvas)
        .navigationTitle("reports.signaturePad.sign")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            Button("reports.signaturePad.done") {
                coordinator.push(ReportsRoute.pdfPreview)
            }
            .buttonStyle(.sd(.primary))
        }
        .enableInjection()
    }

    private var signatureBox: some View {
        RoundedRectangle(cornerRadius: DSSpacing.spacing12)
            .fill(DSColor.fill)
            .frame(height: 240)
            .overlay {
                Canvas { context, size in
                    var line = Path()
                    line.move(to: CGPoint(x: 28, y: size.height - 48))
                    line.addLine(to: CGPoint(x: size.width - 28, y: size.height - 48))
                    context.stroke(line, with: .color(DSColor.lineStrong), lineWidth: 1)

                    for stroke in strokes + [currentStroke] {
                        var path = Path()
                        path.addLines(stroke)
                        context.stroke(
                            path,
                            with: .color(DSColor.textPrimary),
                            style: StrokeStyle(lineWidth: 2.4, lineCap: .round)
                        )
                    }
                }
            }
            .overlay(alignment: .bottom) {
                HStack {
                    Text("reports.signaturePad.signAboveTheLine")
                        .modifier(DSTextStyle.footnote)
                        .foregroundStyle(DSColor.textSecondary)
                    Spacer()
                    Button("reports.signaturePad.clear") {
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
