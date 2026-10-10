// U2 · Today's files

import SystemDesign
import Inject
import SwiftUI

struct UploadFilesView: View {
    @ObserveInjection var inject

    @State private var filter = "All"

    private let filters = ["All", "Waiting", "Failed", "Done"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                Picker("Filter", selection: $filter) {
                    ForEach(filters, id: \.self) { item in
                        Text(item).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, SDSpacing.regular)

                VStack(spacing: 0) {
                    ForEach(FakeData.uploadFiles) { file in
                        fileRow(file)
                        SDDivider()
                    }
                }
            }
            .padding(.vertical, SDSpacing.small)
        }
        .background(SDColor.canvas)
        .navigationTitle("Today’s files")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Filter", systemImage: "line.3.horizontal.decrease") {}
            }
        }
        .enableInjection()
    }

    private func fileRow(_ file: FakeUploadFile) -> some View {
        HStack(spacing: SDSpacing.medium) {
            SitePhotoThumb(variant: file.photoVariant, size: 44)

            VStack(alignment: .leading) {
                Text(file.name)
                    .font(SDFont.subhead.monospaced())
                Text(file.detail)
                    .font(SDFont.subhead)
                    .foregroundStyle(SDColor.textSecondary)
            }

            Spacer()

            SDStatusMarker(kind: file.kind, text: file.status, isLate: file.kind == .critical)
        }
        .frame(minHeight: SDSize.rowMinHeight)
        .padding(.horizontal, SDSpacing.regular)
    }
}

#Preview {
    NavigationStack {
        UploadFilesView()
    }
}
