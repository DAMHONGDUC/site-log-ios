// M3 · Plans

import DesignSystem
import Inject
import SwiftUI

struct PlanListScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.regular) {
            VStack(spacing: 0) {
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

            Text("Plans live on this iPhone and open without signal.")
                .font(DSFont.footnote)
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
