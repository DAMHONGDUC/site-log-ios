// M1 · Markup editor

import DesignSystem
import Inject
import SwiftUI

struct MarkupEditorScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var tool = "pencil"
    @State private var color = DSColor.markup
    @State private var strokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []

    private let tools = ["pencil", "arrow.up.right", "square", "textformat", "ruler"]
    private let colors: [Color] = [.red, DSColor.hiVis, .white, .black]

    var body: some View {
        VStack(spacing: DSSpacing.spacing0) {
            HStack {
                Button("annotation.markupEditor.cancel") {
                    dismiss()
                }
                Spacer()
                Button("annotation.markupEditor.done") {
                    dismiss()
                }
            }
            .foregroundStyle(DSColor.onMedia)
            .padding(DSSpacing.spacing16)

            drawingArea

            toolRow
                .padding(DSSpacing.spacing16)

            colorRow
                .padding(DSSpacing.spacing16)
        }
        .background(DSColor.mediaBackdrop)
        .preferredColorScheme(.dark)
        .enableInjection()
    }

    private var drawingArea: some View {
        SitePhoto(variant: 0, showsCrack: true)
            .overlay {
                Canvas { context, _ in
                    for stroke in strokes + [currentStroke] {
                        var path = Path()
                        path.addLines(stroke)
                        context.stroke(
                            path,
                            with: .color(color),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                        )
                    }
                }
            }
            .clipped()
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

    private var toolRow: some View {
        HStack {
            ForEach(tools, id: \.self) { item in
                Button {
                    tool = item
                } label: {
                    Image(systemName: item)
                        .foregroundStyle(tool == item ? DSColor.hiVis : DSColor.onMedia)
                }
                Spacer()
            }

            Button {
                if !strokes.isEmpty {
                    strokes.removeLast()
                }
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .foregroundStyle(DSColor.onMedia)
            }
            .accessibilityLabel("annotation.markupEditor.undo")
        }
    }

    private var colorRow: some View {
        HStack(spacing: DSSpacing.spacing16) {
            ForEach(colors.indices, id: \.self) { index in
                Button {
                    color = colors[index]
                } label: {
                    Circle()
                        .fill(colors[index])
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
}

#Preview {
    MarkupEditorScreen()
}
