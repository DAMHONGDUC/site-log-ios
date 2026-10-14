import Foundation

// Routes carry ids; the skeleton screens still take fake models
extension FakeData {
    static func project(id: UUID) -> FakeProject? {
        return projects.first { $0.id == id }
    }

    static func issue(id: UUID) -> FakeIssue? {
        return issues.first { $0.id == id }
    }

    static func plan(id: UUID) -> FakePlan? {
        return plans.first { $0.id == id }
    }

    static func room(id: UUID) -> (room: FakeRoom, unitName: String)? {
        for unit in units {
            for room in unit.rooms where room.id == id {
                return (room, unit.name)
            }
        }
        return nil
    }
}
