import SystemDesign
import SwiftUI

struct CameraTopBar: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        HStack {
            Button("Close", systemImage: "chevron.down", action: onClose)
                .labelStyle(.iconOnly)
                .frame(width: SDSize.minTapTarget, height: SDSize.minTapTarget)

            Spacer()

            Text(title)
                .font(SDFont.subhead)

            Spacer()

            Button("Flash", systemImage: "bolt.slash") {}
                .labelStyle(.iconOnly)
                .frame(width: SDSize.minTapTarget, height: SDSize.minTapTarget)
        }
        .foregroundStyle(Color.white)
        .padding(.horizontal)
    }
}

struct CameraBottomBar<Side: View>: View {
    @Binding var mode: String
    let onShutter: () -> Void
    let onThumbnail: () -> Void
    @ViewBuilder let side: Side

    private let modes = ["VIDEO", "PHOTO", "CHECK"]

    var body: some View {
        VStack(spacing: SDSpacing.regular) {
            Picker("Mode", selection: $mode) {
                ForEach(modes, id: \.self) { item in
                    Text(item).tag(item)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Button(action: onThumbnail) {
                    SitePhotoThumb(size: SDSize.minTapTarget)
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

struct CameraSideButton: View {
    let systemImage: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                Text(title)
                    .font(SDFont.caption)
            }
        }
    }
}
