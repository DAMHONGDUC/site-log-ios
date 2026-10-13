// U2 · Today's files

import DesignSystem
import Inject
import SwiftUI

struct UploadFilesView: View {
    @ObserveInjection var inject

    @State private var filter = "All"

    private let filters = ["All", "Waiting", "Failed", "Done"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                Picker("Filter", selection: $filter) {
                    ForEach(filters, id: \.self) { item in
                        Text(item).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, DSSpacing.regular)

                VStack(spacing: 0) {
                    ForEach(FakeData.uploadFiles) { file in
                        fileRow(file)
                        DSDivider()
                    }
                }
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
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
        HStack(spacing: DSSpacing.medium) {
            SitePhotoThumb(variant: file.photoVariant, size: 44)

            VStack(alignment: .leading) {
                Text(file.name)
                    .font(DSFont.subhead.monospaced())
                Text(file.detail)
                    .font(DSFont.subhead)
                    .foregroundStyle(DSColor.textSecondary)
            }

            Spacer()

            DSStatusMarker(kind: file.kind, text: file.status, isLate: file.kind == .critical)
        }
        .frame(minHeight: DSSize.rowMinHeight)
        .padding(.horizontal, DSSpacing.regular)
    }
}

#Preview {
    NavigationStack {
        UploadFilesView()
    }
}
