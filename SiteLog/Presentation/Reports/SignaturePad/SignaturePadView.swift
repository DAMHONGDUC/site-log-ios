// R4 · Signatures

import DesignSystem
import Inject
import SwiftUI

struct SignaturePadView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var party = "Contractor"
    @State private var nameAndRole = "Tran Minh, site manager"
    @State private var strokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                Picker("Party", selection: $party) {
                    Text("Hanh (supervisor) ✓").tag("Supervisor")
                    Text("Contractor").tag("Contractor")
                }
                .pickerStyle(.segmented)

                DSTextField("Name and role", text: $nameAndRole)

                signatureBox

                Text("This is a handwritten signature for internal sign-off, not a certified digital signature.")
                    .font(DSFont.footnote)
                    .foregroundStyle(DSColor.textSecondary)
            }
            .padding(DSSpacing.regular)
        }
        // Drawing must not scroll the page
        .scrollDisabled(true)
        .background(DSColor.canvas)
        .navigationTitle("Sign")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            NavigationLink("Done") {
                PDFPreviewView()
            }
            .buttonStyle(.ds(.primary))
        }
        .enableInjection()
    }

    private var signatureBox: some View {
        RoundedRectangle(cornerRadius: DSSpacing.medium)
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
                        context.stroke(path, with: .color(DSColor.textPrimary), style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
                    }
                }
            }
            .overlay(alignment: .bottom) {
                HStack {
                    Text("Sign above the line")
                        .font(DSFont.footnote)
                        .foregroundStyle(DSColor.textSecondary)
                    Spacer()
                    Button("Clear") {
                        strokes = []
                    }
                    .font(DSFont.subhead.weight(.semibold))
                    .underline()
                    .foregroundStyle(DSColor.textPrimary)
                }
                .padding(.horizontal, DSSpacing.regular)
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
        SignaturePadView()
    }
}
