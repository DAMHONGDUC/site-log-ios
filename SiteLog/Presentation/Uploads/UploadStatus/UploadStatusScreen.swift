// U1 · Sync

import DesignSystem
import Inject
import SwiftUI

struct UploadStatusScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                progressBlock
                    .padding(.horizontal, DSSpacing.spacing16)

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(title: String(localized: "uploads.uploadStatus.waiting"))
                    DSListRow(
                        title: String(localized: "uploads.uploadStatus.3Videos"),
                        subtitle: String(
                            localized: "uploads.uploadStatus.over100MbSoTheyWaitForWiFi"
                        )
                    ) {
                        EmptyView()
                    } trailing: {
                        DSStatusMarker(kind: .waiting)
                    }
                    DSDivider()
                    DSListRow(
                        title: String(localized: "uploads.uploadStatus.1Photo"),
                        subtitle: String(localized: "uploads.uploadStatus.gettingAFreshUploadLink")
                    ) {
                        EmptyView()
                    } trailing: {
                        DSStatusMarker(kind: .waiting)
                    }
                }

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(title: String(localized: "uploads.uploadStatus.didnTUpload"))
                    DSListRow(
                        title: String(localized: "uploads.uploadStatus.img0922Img0925"),
                        subtitle: String(
                            localized: "uploads.uploadStatus.theServerRejectedTheChecksum"
                        )
                    ) {
                        EmptyView()
                    } trailing: {
                        Button("uploads.uploadStatus.retry") {}
                            .buttonStyle(.sd(.secondary, small: true))
                    }
                }

                Button {
                    coordinator.push(UploadsRoute.files)
                } label: {
                    DSListRow(
                        title: String(localized: "uploads.uploadStatus.todaySFiles"),
                        value: String(localized: "uploads.uploadStatus.243"),
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)

                Text("uploads.uploadStatus.someFilesFinishWhileTheIphoneIsIdleYouCanCloseTheApp")
                    .modifier(DSTextStyle.footnote)
                    .foregroundStyle(DSColor.textTertiary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, DSSpacing.spacing16)
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("uploads.uploadStatus.sync")
        .enableInjection()
    }

    private var progressBlock: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
            Text("uploads.uploadStatus.filesProgress")
                .modifier(DSTextStyle.figure)

            DSProgressBar(value: 187.0 / 243.0)

            Text("uploads.uploadStatus.riversideTodayAbout6MinutesLeftOnThisWiFi")
                .modifier(DSTextStyle.subhead)
                .foregroundStyle(DSColor.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        UploadStatusScreen()
    }
}
