import SwiftUI

enum UploadsRoute: Hashable {
    case status
    case files
}

extension View {
    func uploadsDestinations() -> some View {
        navigationDestination(for: UploadsRoute.self) { route in
            switch route {
            case .status:
                UploadStatusScreen()
            case .files:
                UploadFilesScreen()
            }
        }
    }
}
