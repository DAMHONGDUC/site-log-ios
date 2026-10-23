// R5 · PDF preview

import DesignSystem
import Inject
import SwiftUI

struct PDFPreviewScreen: View {
    @ObserveInjection var inject

    var body: some View {
        VStack {
            fakePage
            Text("reports.pDFPreview.1Of18")
                .modifier(DSTextStyle.footnote)
        }
        .padding(DSSpacing.spacing16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.fill)
        .navigationTitle("reports.pDFPreview.r093007Pdf")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: "R-0930-07.pdf")
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            HStack(spacing: DSSpacing.spacing8) {
                Button("reports.pDFPreview.saveToFiles") {}
                    .buttonStyle(.sd(.secondary))
                ShareLink(item: "R-0930-07.pdf") {
                    Text("reports.pDFPreview.send")
                }
                .buttonStyle(.sd(.primary))
            }
        }
        .enableInjection()
    }

    // Placeholder page; the real PDF (PDFKit) replaces it
    private var fakePage: some View {
        VStack(alignment: .leading) {
            Text("reports.pDFPreview.siteInspectionReport")
                .modifier(DSTextStyle.headline)
            Text("reports.pDFPreview.riversideTowerB30September2026HanhNguyen")
                .modifier(DSTextStyle.footnote)
            Text("reports.pDFPreview.7NewIssues1Critical4Major2Minor9IssuesFrom12AugClosed")
                .modifier(DSTextStyle.footnote)
            Spacer()
            Text("reports.pDFPreview.page1Of18")
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
