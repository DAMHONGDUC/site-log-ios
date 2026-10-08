// R5 · PDF preview

import DesignSystem
import Inject
import SwiftUI

struct PDFPreviewView: View {
    @ObserveInjection var inject

    var body: some View {
        VStack {
            fakePage
            Text("1 of 18")
                .font(DSFont.footnote)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.fill)
        .navigationTitle("R-0930-07.pdf")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: "R-0930-07.pdf")
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            HStack(spacing: DSSpacing.small) {
                Button("Save to Files") {}
                    .buttonStyle(.ds(.secondary))
                ShareLink(item: "R-0930-07.pdf") {
                    Text("Send")
                }
                .buttonStyle(.ds(.primary))
            }
        }
        .enableInjection()
    }

    // Placeholder page; the real PDF (PDFKit) replaces it
    private var fakePage: some View {
        VStack(alignment: .leading) {
            Text("Site inspection report")
                .font(DSFont.headline)
            Text("Riverside Tower B · 30 September 2026 · Hanh Nguyen")
                .font(DSFont.footnote)
            Text("7 new issues: 1 critical, 4 major, 2 minor. 9 issues from 12 Aug closed.")
                .font(DSFont.footnote)
            Spacer()
            Text("Page 1 of 18")
                .font(DSFont.footnote)
        }
        .foregroundStyle(Color.black)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
    }
}

#Preview {
    NavigationStack {
        PDFPreviewView()
    }
}
