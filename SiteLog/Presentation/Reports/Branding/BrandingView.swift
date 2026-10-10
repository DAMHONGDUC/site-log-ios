// R3 · Letterhead

import SystemDesign
import Inject
import SwiftUI

struct BrandingView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var company = "Eastline Site Supervision Co."
    @State private var preparedFor = "Riverside Development JSC"
    @State private var footer = "Internal report — not a formal acceptance record"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                HStack(spacing: SDSpacing.medium) {
                    Text("EL")
                        .font(.title3.bold())
                        .foregroundStyle(SDColor.onPrimary)
                        .frame(width: 64, height: 64)
                        .background(SDColor.textPrimary, in: RoundedRectangle(cornerRadius: SDSpacing.medium))

                    VStack(alignment: .leading) {
                        Text("Eastline logo.png")
                            .font(SDFont.body.weight(.medium))
                        Text("Shown on the cover and every page")
                            .font(SDFont.subhead)
                            .foregroundStyle(SDColor.textSecondary)
                    }

                    Spacer()

                    Button("Change") {}
                        .font(SDFont.subhead.weight(.semibold))
                        .underline()
                        .foregroundStyle(SDColor.textPrimary)
                }

                SDTextField("Company", text: $company)
                SDTextField("Prepared for", text: $preparedFor)
                SDTextField("Footer", text: $footer, isMultiline: true)
            }
            .padding(SDSpacing.regular)
        }
        .background(SDColor.canvas)
        .navigationTitle("Your letterhead")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            Button("Save") {
                dismiss()
            }
            .buttonStyle(.sd(.primary))
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        BrandingView()
    }
}
