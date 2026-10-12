// M3 · Plans

import SystemDesign
import Inject
import SwiftUI

struct PlanListView: View {
    @ObserveInjection var inject

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.regular) {
            VStack(spacing: 0) {
                ForEach(FakeData.plans) { plan in
                    NavigationLink {
                        PlanViewerView(plan: plan)
                    } label: {
                        SDListRow(title: plan.title, subtitle: plan.detail, showsChevron: true) {
                            planThumb
                        }
                    }
                    .buttonStyle(.plain)

                    SDDivider()
                }
            }

            Text("Plans live on this iPhone and open without signal.")
                .font(SDFont.footnote)
                .foregroundStyle(SDColor.textTertiary)
                .frame(maxWidth: .infinity)
        }
        .enableInjection()
    }

    private var planThumb: some View {
        Image(systemName: "map")
            .foregroundStyle(SDColor.textSecondary)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            PlanListView()
        }
    }
}
