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
                    .frame(
                        width: DSSpacing.spacing68,
                        height: DSSpacing.spacing68
                    )
                    .background(DSColor.hiVis, in: Circle())
            }
            .accessibilityLabel("components.captureToolbar.capture")

            Spacer()

            right
        }
        .padding(DSSpacing.spacing16)
        .background(DSColor.raised)
    }
}

struct ToolbarSideLabel: View {
    let systemImage: String
    let title: String

    var body: some View {
        VStack {
            Image(systemName: systemImage)
            Text(title)
                .modifier(DSTextStyle.caption)
        }
        .foregroundStyle(DSColor.textPrimary)
    }
}

#Preview {
    VStack {
        Spacer()
        CaptureToolbar {
        } left: {
            Text("components.captureToolbar.end")
        } right: {
            ToolbarSideLabel(
                systemImage: "map",
                title: String(localized: "components.captureToolbar.plan")
            )
        }
    }
}
