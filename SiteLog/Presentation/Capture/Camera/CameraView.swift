//
//  CameraView.swift
//  SiteLog
//
//  C1 · Camera (the home of a walkthrough). Fake viewfinder + laser reading;
//  the real capture session (AVFoundation) arrives in M1.
//

import DesignSystem
import Inject
import SwiftUI

struct CameraView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    var roomName = "7A · Living room"

    @State private var mode = "PHOTO"
    @State private var isReviewShown = false
    @State private var isIssueSheetShown = false

    var body: some View {
        VStack(spacing: 0) {
            CameraTopBar(title: roomName) {
                dismiss()
            }

            viewfinder

            CameraBottomBar(mode: $mode) {
                isReviewShown = true
            } onThumbnail: {
                isReviewShown = true
            } side: {
                CameraSideButton(systemImage: "exclamationmark.triangle", title: "Issue") {
                    isIssueSheetShown = true
                }
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isIssueSheetShown) {
            IssueSheetView()
        }
        .fullScreenCover(isPresented: $isReviewShown) {
            CaptureReviewView()
        }
        .enableInjection()
    }

    private var viewfinder: some View {
        SitePhoto(variant: 0, showsCrack: true)
            .overlay(alignment: .topLeading) {
                laserReading
                    .padding(DSSpacing.regular)
            }
            .clipped()
    }

    // Live reading from the paired laser meter (fake value)
    private var laserReading: some View {
        Text("3.42 m · DISTO")
            .foregroundStyle(Color.white)
            .padding(DSSpacing.small)
            .background(Color.black)
    }
}

#Preview {
    CameraView()
}
