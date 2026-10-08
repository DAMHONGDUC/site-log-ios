// R1 · Walkthrough finished

import DesignSystem
import Inject
import SwiftUI

struct EndSessionView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                VStack(alignment: .leading, spacing: DSSpacing.small) {
                    Text("Tue 30 Sep · 8:12 to 14:00")
                        .font(DSFont.footnote)
                        .foregroundStyle(DSColor.textSecondary)
                    Text("All 82 rooms checked in just under six hours.")
                        .font(.title.bold())
                }
                .padding(.top)
                .padding(.horizontal, DSSpacing.regular)

                Text("You took \(Text("112 photos").bold()), logged \(Text("7 new issues").bold()) and closed \(Text("9").bold()) from last time.")
                    .font(DSFont.body)
                    .padding(.horizontal, DSSpacing.regular)

                VStack(spacing: 0) {
                    DSListRow(title: "Every photo is fingerprinted", subtitle: "Nothing was edited after capture") {
                        Image(systemName: "checkmark.shield")
                            .foregroundStyle(DSColor.success)
                    }
                    DSDivider()
                    NavigationLink {
                        UploadStatusView()
                    } label: {
                        DSListRow(title: "Uploading 87 of 112", subtitle: "Keeps going if you close the app") {
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
            NavigationLink("Make the report") {
                ReportBuilderView()
            }
            .buttonStyle(.ds(.primary))

            Button("Later") {
                dismiss()
            }
            .buttonStyle(.ds(.ghost))
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        EndSessionView()
    }
}
