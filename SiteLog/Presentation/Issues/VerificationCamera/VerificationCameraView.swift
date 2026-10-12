// C3 · Re-check camera

import SystemDesign
import Inject
import SwiftUI

struct VerificationCameraView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    let issue: FakeIssue

    @State private var mode = "CHECK"
    @State private var ghostOpacity = 0.3
    @State private var isOutcomeShown = false

    var body: some View {
        VStack(spacing: 0) {
            CameraTopBar(title: "Re-check #\(issue.number)") {
                dismiss()
            }

            viewfinder

            CameraBottomBar(mode: $mode) {
                isOutcomeShown = true
            } onThumbnail: {
                isOutcomeShown = true
            } side: {
                CameraSideButton(systemImage: "square.3.layers.3d", title: "Ghost") {
                    ghostOpacity = ghostOpacity > 0 ? 0 : 0.3
                }
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $isOutcomeShown) {
            NavigationStack {
                OutcomePickerView(issue: issue)
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
                    .padding(SDSpacing.regular)
            }
            .clipped()
    }

    private var ghostCard: some View {
        VStack(spacing: SDSpacing.small) {
            Text("Line up with 12 Aug · \(Int(ghostOpacity * 100))%")
            Slider(value: $ghostOpacity, in: 0...1)
        }
        .foregroundStyle(Color.white)
        .padding(.vertical)
        .background(Color.black)
    }
}

#Preview {
    VerificationCameraView(issue: FakeData.issues[1])
}
