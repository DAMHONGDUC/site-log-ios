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
                    DSSectionHeader(title: String(localized: "uploads.upload_status.waiting"))
                    DSListRow(
                        title: "3 videos",
                        subtitle: String(
                            localized: "uploads.upload_status.wifi_wait_notice"
                        )
                    ) {
                        EmptyView()
                    } trailing: {
                        DSStatusMarker(kind: .waiting)
                    }
                    DSDivider()
                    DSListRow(
                        title: "1 photo",
                        subtitle: String(localized: "uploads.upload_status.getting_a_fresh_upload_link")
                    ) {
                        EmptyView()
                    } trailing: {
                        DSStatusMarker(kind: .waiting)
                    }
                }

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(title: String(localized: "uploads.upload_status.didn_t_upload"))
                    DSListRow(
                        title: "IMG_0922, IMG_0925",
                        subtitle: String(
                            localized: "uploads.upload_status.checksum_error"
                        )
                    ) {
                        EmptyView()
                    } trailing: {
                        Button("uploads.upload_status.retry") {}
                            .buttonStyle(.sd(.secondary, small: true))
                    }
                }

                Button {
                    coordinator.push(UploadsRoute.files)
                } label: {
                    DSListRow(
                        title: String(localized: "uploads.upload_status.today_s_files"),
                        value: "243",
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)

                Text("uploads.upload_status.background_upload_note")
                    .modifier(DSTextStyle.footnote)
                    .foregroundStyle(DSColor.textTertiary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, DSSpacing.spacing16)
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("uploads.upload_status.sync")
        .enableInjection()
    }

    private var progressBlock: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
            Text(verbatim: "187 of 243 files")
                .modifier(DSTextStyle.figure)

            DSProgressBar(value: 187.0 / 243.0)

            Text(verbatim: "Riverside, today · about 6 minutes left on this Wi-Fi")
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
