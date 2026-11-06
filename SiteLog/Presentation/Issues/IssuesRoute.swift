import Foundation
import SwiftUI

enum IssuesRoute: Hashable {
    case detail(issueID: UUID)
    case outcome(issueID: UUID)
}

extension View {
    func issuesDestinations() -> some View {
        navigationDestination(for: IssuesRoute.self) { route in
            switch route {
            case .detail(let issueID):
                if let issue = FakeData.issue(id: issueID) {
                    IssueDetailScreen(issue: issue)
                }
            case .outcome(let issueID):
                if let issue = FakeData.issue(id: issueID) {
                    OutcomePickerScreen(issue: issue)
                }
            }
        }
    }
}
