// M3 · Plans

import DesignSystem
import Inject
import SwiftUI

struct PlanListScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing16) {
            VStack(spacing: DSSpacing.spacing0) {
                ForEach(FakeData.plans) { plan in
                    Button {
                        coordinator.push(PlansRoute.viewer(planID: plan.id))
                    } label: {
                        DSListRow(title: plan.title, subtitle: plan.detail, showsChevron: true) {
                            planThumb
                        }
                    }
                    .buttonStyle(.plain)

                    DSDivider()
                }
            }

            Text("plans.planList.plansLiveOnThisIphoneAndOpenWithoutSignal")
                .modifier(DSTextStyle.footnote)
                .foregroundStyle(DSColor.textTertiary)
                .frame(maxWidth: .infinity)
        }
        .enableInjection()
    }

    private var planThumb: some View {
        Image(systemName: "map")
            .foregroundStyle(DSColor.textSecondary)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            PlanListScreen()
        }
    }
}
