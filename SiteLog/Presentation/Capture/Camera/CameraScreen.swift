// C1 · Camera

import DesignSystem
import Inject
import SwiftUI

struct CameraScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    var roomName = "7A · Living room"

    @State private var mode = "PHOTO"
    @State private var isReviewShown = false
    @State private var isIssueSheetShown = false

    var body: some View {
        VStack(spacing: DSSpacing.spacing0) {
            CameraTopBar(title: roomName) {
                dismiss()
            }

            viewfinder

            CameraBottomBar(mode: $mode) {
                isReviewShown = true
            } onThumbnail: {
                isReviewShown = true
            } side: {
                CameraSideButton(
                    systemImage: "exclamationmark.triangle",
                    title: String(localized: "capture.camera.issue")
                ) {
                    isIssueSheetShown = true
                }
            }
        }
        .background(DSColor.mediaBackdrop)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isIssueSheetShown) {
            IssueSheetScreen()
        }
        .fullScreenCover(isPresented: $isReviewShown) {
            CaptureReviewScreen()
        }
        .enableInjection()
    }

    private var viewfinder: some View {
        SitePhoto(variant: 0, showsCrack: true)
            .overlay(alignment: .topLeading) {
                laserReading
                    .padding(DSSpacing.spacing16)
            }
            .clipped()
    }

    private var laserReading: some View {
        Text(verbatim: "3.42 m · DISTO")
            .foregroundStyle(DSColor.onMedia)
            .padding(DSSpacing.spacing8)
            .background(DSColor.mediaBackdrop)
    }
}

#Preview {
    CameraScreen()
}
