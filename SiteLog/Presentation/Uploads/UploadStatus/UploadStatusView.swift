// U1 · Sync

import SystemDesign
import Inject
import SwiftUI

struct UploadStatusView: View {
    @ObserveInjection var inject

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                progressBlock
                    .padding(.horizontal, SDSpacing.regular)

                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    SDSectionHeader(title: "Waiting")
                    SDListRow(title: "3 videos", subtitle: "Over 100 MB, so they wait for Wi-Fi") {
                        EmptyView()
                    } trailing: {
                        SDStatusMarker(kind: .waiting)
                    }
                    SDDivider()
                    SDListRow(title: "1 photo", subtitle: "Getting a fresh upload link") {
                        EmptyView()
                    } trailing: {
                        SDStatusMarker(kind: .waiting)
                    }
                }

                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    SDSectionHeader(title: "Didn’t upload")
                    SDListRow(title: "IMG_0922, IMG_0925", subtitle: "The server rejected the checksum") {
                        EmptyView()
                    } trailing: {
                        Button("Retry") {}
                            .buttonStyle(.sd(.secondary, small: true))
                    }
                }

                NavigationLink {
                    UploadFilesView()
                } label: {
                    SDListRow(title: "Today’s files", value: "243", showsChevron: true)
                }
                .buttonStyle(.plain)

                Text("Some files finish while the iPhone is idle. You can close the app.")
                    .font(SDFont.footnote)
                    .foregroundStyle(SDColor.textTertiary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, SDSpacing.regular)
            }
            .padding(.vertical, SDSpacing.small)
        }
        .background(SDColor.canvas)
        .navigationTitle("Sync")
        .enableInjection()
    }

    private var progressBlock: some View {
        VStack(alignment: .leading, spacing: SDSpacing.small) {
            Text("187 \(Text("of 243 files").foregroundStyle(SDColor.textTertiary))")
                .font(SDFont.figure)

            SDProgressBar(value: 187.0 / 243.0)

            Text("Riverside, today · about 6 minutes left on this Wi-Fi")
                .font(SDFont.subhead)
                .foregroundStyle(SDColor.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        UploadStatusView()
    }
}
