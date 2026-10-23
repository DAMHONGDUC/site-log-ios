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
                    Text("projects.endSession.tue30Sep812To1400")
                        .modifier(DSTextStyle.footnote)
                        .foregroundStyle(DSColor.textSecondary)
                    Text("projects.endSession.all82RoomsCheckedInJustUnderSixHours")
                        .modifier(DSTextStyle.pageTitle)
                }
                .padding(.top)
                .padding(.horizontal, DSSpacing.spacing16)

                Text("projects.endSession.summary")
                    .modifier(DSTextStyle.body)
                    .padding(.horizontal, DSSpacing.spacing16)

                VStack(spacing: DSSpacing.spacing0) {
                    DSListRow(
                        title: String(localized: "projects.endSession.everyPhotoIsFingerprinted"),
                        subtitle: String(
                            localized: "projects.endSession.nothingWasEditedAfterCapture"
                        )
                    ) {
                        Image(systemName: "checkmark.shield")
                            .foregroundStyle(DSColor.success)
                    }
                    DSDivider()
                    Button {
                        coordinator.push(UploadsRoute.status)
                    } label: {
                        DSListRow(
                            title: String(localized: "projects.endSession.uploading87Of112"),
                            subtitle: String(
                                localized: "projects.endSession.keepsGoingIfYouCloseTheApp"
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
            Button("projects.endSession.makeTheReport") {
                coordinator.push(ReportsRoute.builder)
            }
            .buttonStyle(.sd(.primary))

            Button("projects.endSession.later") {
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
