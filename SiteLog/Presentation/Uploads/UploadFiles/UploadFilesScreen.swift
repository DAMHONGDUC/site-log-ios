// U2 · Today's files

import DesignSystem
import Inject
import SwiftUI

struct UploadFilesScreen: View {
    @ObserveInjection var inject

    @State private var filter = "uploads.filter.all"

    private let filters = [
        "uploads.filter.all", "uploads.filter.waiting", "uploads.filter.failed",
        "uploads.filter.done",
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                Picker("uploads.uploadFiles.filter", selection: $filter) {
                    ForEach(filters, id: \.self) { item in
                        Text(NSLocalizedString(item, comment: "")).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, DSSpacing.spacing16)

                VStack(spacing: DSSpacing.spacing0) {
                    ForEach(FakeData.uploadFiles) { file in
                        fileRow(file)
                        DSDivider()
                    }
                }
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("uploads.uploadFiles.todaySFiles")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("uploads.uploadFiles.filter2", systemImage: "line.3.horizontal.decrease") {}
            }
        }
        .enableInjection()
    }

    private func fileRow(_ file: FakeUploadFile) -> some View {
        HStack(spacing: DSSpacing.spacing12) {
            SitePhotoThumb(variant: file.photoVariant, size: 44)

            VStack(alignment: .leading) {
                Text(file.name)
                    .modifier(DSTextStyle.subheadMonospaced)
                Text(file.detail)
                    .modifier(DSTextStyle.subhead)
                    .foregroundStyle(DSColor.textSecondary)
            }

            Spacer()

            DSStatusMarker(kind: file.kind, text: file.status, isLate: file.kind == .critical)
        }
        .frame(minHeight: DSSpacing.spacing52)
        .padding(.horizontal, DSSpacing.spacing16)
    }
}

#Preview {
    NavigationStack {
        UploadFilesScreen()
    }
}
