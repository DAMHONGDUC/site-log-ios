import SystemDesign
import Inject
import SwiftUI

struct CaptureReviewView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var isMarkupShown = false

    var body: some View {
        VStack(spacing: 0) {
            SitePhoto(variant: 0, showsCrack: true)
                .clipped()
                .overlay(alignment: .bottomLeading) {
                    Text("10:42:18 · SHA-256 7f3a…c91e")
                        .font(SDFont.code)
                        .foregroundStyle(Color.white)
                        .padding()
                }

            HStack(spacing: SDSpacing.small) {
                Button("Retake") {
                    dismiss()
                }
                .buttonStyle(.sd(.secondary))

                Button("Mark up") {
                    isMarkupShown = true
                }
                .buttonStyle(.sd(.secondary))

                Button("Use photo") {
                    dismiss()
                }
                .buttonStyle(.sd(.primary))
            }
            .padding(SDSpacing.regular)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $isMarkupShown) {
            MarkupEditorView()
        }
        .enableInjection()
    }
}

#Preview {
    CaptureReviewView()
}
