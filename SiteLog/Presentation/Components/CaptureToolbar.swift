import SystemDesign
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
                    .foregroundStyle(SDColor.onHiVis)
                    .frame(width: SDSize.captureButton, height: SDSize.captureButton)
                    .background(SDColor.hiVis, in: Circle())
            }
            .accessibilityLabel("Capture")

            Spacer()

            right
        }
        .padding()
        .background(SDColor.raised)
    }
}

struct ToolbarSideLabel: View {
    let systemImage: String
    let title: String

    var body: some View {
        VStack {
            Image(systemName: systemImage)
            Text(title)
                .font(SDFont.caption)
        }
        .foregroundStyle(SDColor.textPrimary)
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
