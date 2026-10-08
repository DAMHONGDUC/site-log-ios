//
//  CameraControls.swift
//  SiteLog
//
//  Camera chrome shared by C1 (camera) and C3 (re-check camera):
//  top bar and shutter row. The viewfinder is a SitePhoto until AVFoundation lands.
//

import DesignSystem
import SwiftUI

// Close · room · flash
struct CameraTopBar: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        HStack {
            Button("Close", systemImage: "chevron.down", action: onClose)
                .labelStyle(.iconOnly)
                .frame(width: DSSize.minTapTarget, height: DSSize.minTapTarget)

            Spacer()

            Text(title)
                .font(DSFont.subhead)

            Spacer()

            Button("Flash", systemImage: "bolt.slash") {}
                .labelStyle(.iconOnly)
                .frame(width: DSSize.minTapTarget, height: DSSize.minTapTarget)
        }
        .foregroundStyle(Color.white)
        .padding(.horizontal)
    }
}

// VIDEO · PHOTO · CHECK, then thumbnail · shutter · side button
struct CameraBottomBar<Side: View>: View {
    @Binding var mode: String
    let onShutter: () -> Void
    let onThumbnail: () -> Void
    @ViewBuilder let side: Side

    private let modes = ["VIDEO", "PHOTO", "CHECK"]

    var body: some View {
        VStack(spacing: DSSpacing.regular) {
            Picker("Mode", selection: $mode) {
                ForEach(modes, id: \.self) { item in
                    Text(item).tag(item)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Button(action: onThumbnail) {
                    SitePhotoThumb(size: DSSize.minTapTarget)
                }

                Spacer()

                Button(action: onShutter) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                }
                .accessibilityLabel("Take photo")

                Spacer()

                side
            }
        }
        .foregroundStyle(Color.white)
        .padding()
    }
}

// Icon button with a caption under it ("Issue", "Ghost")
struct CameraSideButton: View {
    let systemImage: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                Text(title)
                    .font(DSFont.caption)
            }
        }
    }
}
