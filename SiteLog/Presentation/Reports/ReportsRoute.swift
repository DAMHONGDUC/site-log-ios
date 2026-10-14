import SwiftUI

enum ReportsRoute: Hashable {
    case builder
    case branding
    case signature
    case pdfPreview
}

extension View {
    func reportsDestinations() -> some View {
        navigationDestination(for: ReportsRoute.self) { route in
            switch route {
            case .builder:
                ReportBuilderScreen()
            case .branding:
                BrandingScreen()
            case .signature:
                SignaturePadScreen()
            case .pdfPreview:
                PDFPreviewScreen()
            }
        }
    }
}
