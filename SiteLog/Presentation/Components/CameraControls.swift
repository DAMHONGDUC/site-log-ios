import DesignSystem
import SwiftUI

struct CameraTopBar: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        HStack {
            Button("components.cameraControls.close", systemImage: "chevron.down", action: onClose)
                .labelStyle(.iconOnly)
                .frame(width: DSSpacing.spacing44, height: DSSpacing.spacing44)

            Spacer()

            Text(title)
                .modifier(DSTextStyle.subhead)

            Spacer()

            Button("components.cameraControls.flash", systemImage: "bolt.slash") {}
                .labelStyle(.iconOnly)
                .frame(width: DSSpacing.spacing44, height: DSSpacing.spacing44)
        }
        .foregroundStyle(DSColor.onMedia)
        .padding(.horizontal)
    }
}

struct CameraBottomBar<Side: View>: View {
    @Binding var mode: String
    let onShutter: () -> Void
    let onThumbnail: () -> Void
    @ViewBuilder let side: Side

    private let modes = [
        "components.camera.mode.video", "components.camera.mode.photo",
        "components.camera.mode.check",
    ]

    var body: some View {
        VStack(spacing: DSSpacing.spacing16) {
            Picker("components.cameraControls.mode", selection: $mode) {
                ForEach(modes, id: \.self) { item in
                    Text(NSLocalizedString(item, comment: "")).tag(item)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Button(action: onThumbnail) {
                    SitePhotoThumb(size: DSSpacing.spacing44)
                }

                Spacer()

                Button(action: onShutter) {
                    Circle()
                        .fill(DSColor.onMedia)
                        .frame(width: DSSpacing.spacing70, height: DSSpacing.spacing70)
                }
                .accessibilityLabel("components.cameraControls.takePhoto")

                Spacer()

                side
            }
        }
        .foregroundStyle(DSColor.onMedia)
        .padding(DSSpacing.spacing16)
    }
}

struct CameraSideButton: View {
    let systemImage: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                Text(title)
                    .modifier(DSTextStyle.caption)
            }
        }
    }
}
