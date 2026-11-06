import Foundation
import SwiftUI

enum PlansRoute: Hashable {
    case viewer(planID: UUID)
}

extension View {
    func plansDestinations() -> some View {
        navigationDestination(for: PlansRoute.self) { route in
            switch route {
            case .viewer(let planID):
                if let plan = FakeData.plan(id: planID) {
                    PlanViewerScreen(plan: plan)
                }
            }
        }
    }
}
