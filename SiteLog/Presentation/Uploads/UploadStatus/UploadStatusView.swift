//
//  UploadStatusView.swift
//  SiteLog
//
//  U1 · Sync tab: one big figure, what is waiting, what failed.
//  "Waiting" is never red.
//

import DesignSystem
import Inject
import SwiftUI

struct UploadStatusView: View {
    @ObserveInjection var inject

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                progressBlock
                    .padding(.horizontal, DSSpacing.regular)

                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: "Waiting")
                    DSListRow(title: "3 videos", subtitle: "Over 100 MB, so they wait for Wi-Fi") {
                        EmptyView()
                    } trailing: {
                        DSStatusMarker(kind: .waiting)
                    }
                    DSDivider()
                    DSListRow(title: "1 photo", subtitle: "Getting a fresh upload link") {
                        EmptyView()
                    } trailing: {
                        DSStatusMarker(kind: .waiting)
                    }
                }

                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: "Didn’t upload")
                    DSListRow(title: "IMG_0922, IMG_0925", subtitle: "The server rejected the checksum") {
                        EmptyView()
                    } trailing: {
                        Button("Retry") {}
                            .buttonStyle(.ds(.secondary, small: true))
                    }
                }

                NavigationLink {
                    UploadFilesView()
                } label: {
                    DSListRow(title: "Today’s files", value: "243", showsChevron: true)
                }
                .buttonStyle(.plain)

                Text("Some files finish while the iPhone is idle. You can close the app.")
                    .font(DSFont.footnote)
                    .foregroundStyle(DSColor.textTertiary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, DSSpacing.regular)
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
        .navigationTitle("Sync")
        .enableInjection()
    }

    private var progressBlock: some View {
        VStack(alignment: .leading, spacing: DSSpacing.small) {
            Text("187 \(Text("of 243 files").foregroundStyle(DSColor.textTertiary))")
                .font(DSFont.figure)

            DSProgressBar(value: 187.0 / 243.0)

            Text("Riverside, today · about 6 minutes left on this Wi-Fi")
                .font(DSFont.subhead)
                .foregroundStyle(DSColor.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        UploadStatusView()
    }
}
