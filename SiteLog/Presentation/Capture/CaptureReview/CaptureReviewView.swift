//
//  CaptureReviewView.swift
//  SiteLog
//
//  Photo just taken: hash + time, then Retake · Mark up · Use photo.
//  No mockup yet — kept minimal.
//

import DesignSystem
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
                        .font(DSFont.code)
                        .foregroundStyle(Color.white)
                        .padding()
                }

            HStack(spacing: DSSpacing.small) {
                Button("Retake") {
                    dismiss()
                }
                .buttonStyle(.ds(.secondary))

                Button("Mark up") {
                    isMarkupShown = true
                }
                .buttonStyle(.ds(.secondary))

                Button("Use photo") {
                    dismiss()
                }
                .buttonStyle(.ds(.primary))
            }
            .padding(DSSpacing.regular)
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
