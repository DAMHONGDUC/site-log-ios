import Foundation
import SwiftUI

enum ProjectsRoute: Hashable {
    case detail(projectID: UUID)
    case survey
    case endSession
    case bulkLocations
    case cloneTree
    case room(roomID: UUID)
}

extension View {
    func projectsDestinations() -> some View {
        navigationDestination(for: ProjectsRoute.self) { route in
            switch route {
            case .detail(let projectID):
                if let project = FakeData.project(id: projectID) {
                    ProjectDetailScreen(project: project)
                }
            case .survey:
                SurveyScreen()
            case .endSession:
                EndSessionScreen()
            case .bulkLocations:
                BulkLocationsScreen()
            case .cloneTree:
                CloneTreeScreen()
            case .room(let roomID):
                if let found = FakeData.room(id: roomID) {
                    RoomScreen(room: found.room, unitName: found.unitName)
                }
            }
        }
    }
}
