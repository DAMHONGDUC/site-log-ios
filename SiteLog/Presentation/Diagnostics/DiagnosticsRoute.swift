import SwiftUI

enum DiagnosticsRoute: Hashable {
    case export
}

extension View {
    func diagnosticsDestinations() -> some View {
        navigationDestination(for: DiagnosticsRoute.self) { route in
            switch route {
            case .export:
                DiagnosticExportScreen()
            }
        }
    }
}
