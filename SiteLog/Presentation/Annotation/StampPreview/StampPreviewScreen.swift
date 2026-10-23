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
                    "annotation.stampPreview.timeCheckedAgainstTheNetworkWithin2SAndGps6MSoTheStampCanBeTrusted"
                )
                .modifier(DSTextStyle.footnote)
                .foregroundStyle(DSColor.textSecondary)
                .padding(.horizontal, DSSpacing.spacing16)

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(title: String(localized: "annotation.stampPreview.stampShows"))
                    toggleRow(
                        String(localized: "annotation.stampPreview.dateAndTime"),
                        isOn: $showsDate
                    )
                    DSDivider()
                    toggleRow(
                        String(localized: "annotation.stampPreview.projectAndRoom"),
                        isOn: $showsRoom
                    )
                    DSDivider()
                    toggleRow(
                        String(localized: "annotation.stampPreview.myMarkup"),
                        isOn: $showsMarkup
                    )
                }
            }
        }
        .background(DSColor.canvas)
        .navigationTitle("annotation.stampPreview.sharePhoto")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            ShareLink(item: "Verify at sitelog.app/v/7F3K-92QD") {
                Label("annotation.stampPreview.share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.sd(.primary))
        }
        .enableInjection()
    }

    private var stampStrip: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing0) {
            if showsDate {
                Text("annotation.stampPreview.30Sep202610421807RiversideTowerB")
            }
            if showsRoom {
                Text("annotation.stampPreview.level77ALivingRoom1072971067215")
            }
            Text("annotation.stampPreview.verifyAtSitelogAppV7F3K92Qd")
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
