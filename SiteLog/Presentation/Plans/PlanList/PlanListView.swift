// M3 · Plans

import DesignSystem
import Inject
import SwiftUI

struct PlanListView: View {
    @ObserveInjection var inject

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.regular) {
            VStack(spacing: 0) {
                ForEach(FakeData.plans) { plan in
                    NavigationLink {
                        PlanViewerView(plan: plan)
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
            PlanListView()
        }
    }
}
