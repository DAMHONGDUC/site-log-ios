//
//  BrandingView.swift
//  SiteLog
//
//  R3 · Your letterhead: logo, company, client, footer.
//

import DesignSystem
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
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                HStack(spacing: DSSpacing.medium) {
                    Text("EL")
                        .font(.title3.bold())
                        .foregroundStyle(DSColor.onPrimary)
                        .frame(width: 64, height: 64)
                        .background(DSColor.textPrimary, in: RoundedRectangle(cornerRadius: DSSpacing.medium))

                    VStack(alignment: .leading) {
                        Text("Eastline logo.png")
                            .font(DSFont.body.weight(.medium))
                        Text("Shown on the cover and every page")
                            .font(DSFont.subhead)
                            .foregroundStyle(DSColor.textSecondary)
                    }

                    Spacer()

                    Button("Change") {}
                        .font(DSFont.subhead.weight(.semibold))
                        .underline()
                        .foregroundStyle(DSColor.textPrimary)
                }

                DSTextField("Company", text: $company)
                DSTextField("Prepared for", text: $preparedFor)
                DSTextField("Footer", text: $footer, isMultiline: true)
            }
            .padding(DSSpacing.regular)
        }
        .background(DSColor.canvas)
        .navigationTitle("Your letterhead")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            Button("Save") {
                dismiss()
            }
            .buttonStyle(.ds(.primary))
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        BrandingView()
    }
}
