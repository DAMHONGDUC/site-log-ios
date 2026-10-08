// M1 · Markup editor

import DesignSystem
import Inject
import SwiftUI

struct MarkupEditorView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var tool = "pencil"
    @State private var color = Color.red
    @State private var strokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []

    private let tools = ["pencil", "arrow.up.right", "square", "textformat", "ruler"]
    private let colors: [Color] = [.red, DSColor.hiVis, .white, .black]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            .foregroundStyle(Color.white)
            .padding()

            drawingArea

            toolRow
                .padding()

            colorRow
                .padding()
        }
        .background(Color.black)
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
                        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
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
                        .foregroundStyle(tool == item ? DSColor.hiVis : Color.white)
                }
                Spacer()
            }

            Button {
                if !strokes.isEmpty {
                    strokes.removeLast()
                }
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .foregroundStyle(Color.white)
            }
            .accessibilityLabel("Undo")
        }
    }

    private var colorRow: some View {
        HStack(spacing: DSSpacing.regular) {
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
    MarkupEditorView()
}
