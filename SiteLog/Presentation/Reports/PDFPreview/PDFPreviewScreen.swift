// R5 · PDF preview

import DesignSystem
import Inject
import SwiftUI

struct PDFPreviewScreen: View {
    @ObserveInjection var inject

    var body: some View {
        VStack {
            fakePage
            Text(verbatim: "1 of 18")
                .modifier(DSTextStyle.footnote)
        }
        .padding(DSSpacing.spacing16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.fill)
        .navigationTitle(Text(verbatim: "R-0930-07.pdf"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: "R-0930-07.pdf")
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            HStack(spacing: DSSpacing.spacing8) {
                Button("reports.pdf_preview.save_to_files") {}
                    .buttonStyle(.sd(.secondary))
                ShareLink(item: "R-0930-07.pdf") {
                    Text("reports.pdf_preview.send")
                }
                .buttonStyle(.sd(.primary))
            }
        }
        .enableInjection()
    }

    // Placeholder page; the real PDF (PDFKit) replaces it
    private var fakePage: some View {
        VStack(alignment: .leading) {
            Text("reports.pdf_preview.site_inspection_report")
                .modifier(DSTextStyle.headline)
            Text(verbatim: "Riverside Tower B · 30 September 2026 · Hanh Nguyen")
                .modifier(DSTextStyle.footnote)
            Text(verbatim: "7 new issues: 1 critical, 4 major, 2 minor. 9 issues from 12 Aug closed.")
                .modifier(DSTextStyle.footnote)
            Spacer()
            Text(verbatim: "Page 1 of 18")
                .modifier(DSTextStyle.footnote)
        }
        .foregroundStyle(DSColor.mediaBackdrop)
        .padding(DSSpacing.spacing16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DSColor.onMedia)
    }
}

#Preview {
    NavigationStack {
        PDFPreviewScreen()
    }
}
