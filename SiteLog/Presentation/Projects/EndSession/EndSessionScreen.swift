// R1 · Walkthrough finished

import DesignSystem
import Inject
import SwiftUI

struct EndSessionScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
                    Text(verbatim: "Tue 30 Sep · 8:12 to 14:00")
                        .modifier(DSTextStyle.footnote)
                        .foregroundStyle(DSColor.textSecondary)
                    Text(verbatim: "All 82 rooms checked in just under six hours.")
                        .modifier(DSTextStyle.pageTitle)
                }
                .padding(.top)
                .padding(.horizontal, DSSpacing.spacing16)

                Text(verbatim: "You took 112 photos, logged 7 new issues and closed 9 from last time.")
                    .modifier(DSTextStyle.body)
                    .padding(.horizontal, DSSpacing.spacing16)

                VStack(spacing: DSSpacing.spacing0) {
                    DSListRow(
                        title: String(localized: "projects.end_session.every_photo_is_fingerprinted"),
                        subtitle: "Nothing was edited after capture"
                    ) {
                        Image(systemName: "checkmark.shield")
                            .foregroundStyle(DSColor.success)
                    }
                    DSDivider()
                    Button {
                        coordinator.push(UploadsRoute.status)
                    } label: {
                        DSListRow(
                            title: "Uploading 87 of 112",
                            subtitle: String(
                                localized: "projects.end_session.background_upload_note"
                            )
                        ) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundStyle(DSColor.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .background(DSColor.canvas)
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            Button("projects.end_session.make_the_report") {
                coordinator.push(ReportsRoute.builder)
            }
            .buttonStyle(.sd(.primary))

            Button("projects.end_session.later") {
                dismiss()
            }
            .buttonStyle(.sd(.ghost))
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        EndSessionScreen()
    }
}
