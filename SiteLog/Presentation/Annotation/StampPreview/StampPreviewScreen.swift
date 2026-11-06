// M2 · Share stamped photo

import DesignSystem
import Inject
import SwiftUI

struct StampPreviewScreen: View {
    @ObserveInjection var inject

    @State private var showsDate = true
    @State private var showsRoom = true
    @State private var showsMarkup = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                SitePhoto(variant: 0, showsCrack: true)
                    .frame(height: DSSpacing.spacing300)
                    .overlay(alignment: .bottom) {
                        stampStrip
                    }

                Text(
                    "annotation.stamp_preview.time_accuracy_note"
                )
                .modifier(DSTextStyle.footnote)
                .foregroundStyle(DSColor.textSecondary)
                .padding(.horizontal, DSSpacing.spacing16)

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(title: String(localized: "annotation.stamp_preview.stamp_shows"))
                    toggleRow(
                        String(localized: "annotation.stamp_preview.date_and_time"),
                        isOn: $showsDate
                    )
                    DSDivider()
                    toggleRow(
                        String(localized: "annotation.stamp_preview.project_and_room"),
                        isOn: $showsRoom
                    )
                    DSDivider()
                    toggleRow(
                        String(localized: "annotation.stamp_preview.my_markup"),
                        isOn: $showsMarkup
                    )
                }
            }
        }
        .background(DSColor.canvas)
        .navigationTitle("annotation.stamp_preview.share_photo")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            ShareLink(item: "Verify at sitelog.app/v/7F3K-92QD") {
                Label("annotation.stamp_preview.share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.sd(.primary))
        }
        .enableInjection()
    }

    private var stampStrip: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing0) {
            if showsDate {
                Text(verbatim: "30 Sep 2026 10:42:18 +07 · Riverside Tower B")
            }
            if showsRoom {
                Text(verbatim: "Level 7 › 7A › Living room · 10.7297, 106.7215")
            }
            Text(verbatim: "Verify at sitelog.app/v/7F3K-92QD")
        }
        .modifier(DSTextStyle.code)
        .foregroundStyle(DSColor.onMedia)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
        .background(DSColor.mediaBackdrop.opacity(0.72))
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .tint(DSColor.success)
            .frame(minHeight: DSSpacing.spacing52)
            .padding(.horizontal, DSSpacing.spacing16)
    }
}

#Preview {
    NavigationStack {
        StampPreviewScreen()
    }
}
