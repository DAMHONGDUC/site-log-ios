import DesignSystem
import Inject
import SwiftUI

struct CaptureReviewScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var isMarkupShown = false

    var body: some View {
        VStack(spacing: DSSpacing.spacing0) {
            SitePhoto(variant: 0, showsCrack: true)
                .clipped()
                .overlay(alignment: .bottomLeading) {
                    Text("capture.captureReview.104218Sha2567F3AC91E")
                        .modifier(DSTextStyle.code)
                        .foregroundStyle(DSColor.onMedia)
                        .padding(DSSpacing.spacing16)
                }

            HStack(spacing: DSSpacing.spacing8) {
                Button("capture.captureReview.retake") {
                    dismiss()
                }
                .buttonStyle(.sd(.secondary))

                Button("capture.captureReview.markUp") {
                    isMarkupShown = true
                }
                .buttonStyle(.sd(.secondary))

                Button("capture.captureReview.usePhoto") {
                    dismiss()
                }
                .buttonStyle(.sd(.primary))
            }
            .padding(DSSpacing.spacing16)
        }
        .background(DSColor.mediaBackdrop)
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $isMarkupShown) {
            MarkupEditorScreen()
        }
        .enableInjection()
    }
}

#Preview {
    CaptureReviewScreen()
}
