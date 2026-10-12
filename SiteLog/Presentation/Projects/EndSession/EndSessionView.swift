// R1 · Walkthrough finished

import SystemDesign
import Inject
import SwiftUI

struct EndSessionView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                VStack(alignment: .leading, spacing: SDSpacing.small) {
                    Text("Tue 30 Sep · 8:12 to 14:00")
                        .font(SDFont.footnote)
                        .foregroundStyle(SDColor.textSecondary)
                    Text("All 82 rooms checked in just under six hours.")
                        .font(.title.bold())
                }
                .padding(.top)
                .padding(.horizontal, SDSpacing.regular)

                Text("You took \(Text("112 photos").bold()), logged \(Text("7 new issues").bold()) and closed \(Text("9").bold()) from last time.")
                    .font(SDFont.body)
                    .padding(.horizontal, SDSpacing.regular)

                VStack(spacing: 0) {
                    SDListRow(title: "Every photo is fingerprinted", subtitle: "Nothing was edited after capture") {
                        Image(systemName: "checkmark.shield")
                            .foregroundStyle(SDColor.success)
                    }
                    SDDivider()
                    NavigationLink {
                        UploadStatusView()
                    } label: {
                        SDListRow(title: "Uploading 87 of 112", subtitle: "Keeps going if you close the app") {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundStyle(SDColor.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .background(SDColor.canvas)
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            NavigationLink("Make the report") {
                ReportBuilderView()
            }
            .buttonStyle(.sd(.primary))

            Button("Later") {
                dismiss()
            }
            .buttonStyle(.sd(.ghost))
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        EndSessionView()
    }
}
