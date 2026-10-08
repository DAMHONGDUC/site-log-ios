//
//  CaptureToolbar.swift
//  SiteLog
//
//  Bottom toolbar with the yellow capture button in the middle.
//

import DesignSystem
import SwiftUI

struct CaptureToolbar<Left: View, Right: View>: View {
    let onCapture: () -> Void
    @ViewBuilder let left: Left
    @ViewBuilder let right: Right

    var body: some View {
        HStack {
            left

            Spacer()

            Button(action: onCapture) {
                Image(systemName: "camera")
                    .foregroundStyle(DSColor.onHiVis)
                    .frame(width: DSSize.captureButton, height: DSSize.captureButton)
                    .background(DSColor.hiVis, in: Circle())
            }
            .accessibilityLabel("Capture")

            Spacer()

            right
        }
        .padding()
        .background(DSColor.raised)
    }
}

// Icon + caption used on both sides of the toolbar ("Issue", "Plan")
struct ToolbarSideLabel: View {
    let systemImage: String
    let title: String

    var body: some View {
        VStack {
            Image(systemName: systemImage)
            Text(title)
                .font(DSFont.caption)
        }
        .foregroundStyle(DSColor.textPrimary)
    }
}

#Preview {
    VStack {
        Spacer()
        CaptureToolbar {} left: {
            Text("End")
        } right: {
            ToolbarSideLabel(systemImage: "map", title: "Plan")
        }
    }
}
