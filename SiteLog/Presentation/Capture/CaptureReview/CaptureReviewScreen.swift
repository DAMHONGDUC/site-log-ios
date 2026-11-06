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
                    Text(verbatim: "10:42:18 · SHA-256 7f3a…c91e")
                        .modifier(DSTextStyle.code)
                        .foregroundStyle(DSColor.onMedia)
                        .padding(DSSpacing.spacing16)
                }

            HStack(spacing: DSSpacing.spacing8) {
                Button("capture.capture_review.retake") {
                    dismiss()
                }
                .buttonStyle(.sd(.secondary))

                Button("capture.capture_review.mark_up") {
                    isMarkupShown = true
                }
                .buttonStyle(.sd(.secondary))

                Button("capture.capture_review.use_photo") {
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
