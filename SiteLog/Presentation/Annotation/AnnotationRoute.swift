import SwiftUI

enum AnnotationRoute: Hashable {
    case stampPreview
}

extension View {
    func annotationDestinations() -> some View {
        navigationDestination(for: AnnotationRoute.self) { route in
            switch route {
            case .stampPreview:
                StampPreviewScreen()
            }
        }
    }
}
