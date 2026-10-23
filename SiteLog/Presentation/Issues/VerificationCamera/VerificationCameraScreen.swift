// C3 · Re-check camera

import DesignSystem
import Inject
import SwiftUI

struct VerificationCameraScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    let issue: FakeIssue

    @State private var mode = "CHECK"
    @State private var ghostOpacity = 0.3
    @State private var isOutcomeShown = false

    var body: some View {
        VStack(spacing: DSSpacing.spacing0) {
            CameraTopBar(
                title: String.localizedStringWithFormat(
                    String(localized: "issues.verificationCamera.title"),
                    issue.number
                )
            ) {
                dismiss()
            }

            viewfinder

            CameraBottomBar(mode: $mode) {
                isOutcomeShown = true
            } onThumbnail: {
                isOutcomeShown = true
            } side: {
                CameraSideButton(
                    systemImage: "square.3.layers.3d",
                    title: String(localized: "issues.verificationCamera.ghost")
                ) {
                    ghostOpacity = ghostOpacity > 0 ? 0 : 0.3
                }
            }
        }
        .background(DSColor.mediaBackdrop)
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $isOutcomeShown) {
            NavigationStack {
                OutcomePickerScreen(issue: issue)
            }
        }
        .enableInjection()
    }

    private var viewfinder: some View {
        SitePhoto(variant: issue.photoVariant)
            .overlay {
                // Old photo as a faded guide
                SitePhoto(variant: issue.photoVariant, showsCrack: true)
                    .opacity(ghostOpacity)
            }
            .overlay(alignment: .top) {
                ghostCard
                    .padding(DSSpacing.spacing16)
            }
            .clipped()
    }

    private var ghostCard: some View {
        VStack(spacing: DSSpacing.spacing8) {
            Text(
                String.localizedStringWithFormat(
                    String(localized: "issues.verificationCamera.ghostOpacity"),
                    Int(ghostOpacity * 100)
                )
            )
            Slider(value: $ghostOpacity, in: 0...1)
        }
        .foregroundStyle(DSColor.onMedia)
        .padding(.vertical)
        .background(DSColor.mediaBackdrop)
    }
}

#Preview {
    VerificationCameraScreen(issue: FakeData.issues[1])
}
