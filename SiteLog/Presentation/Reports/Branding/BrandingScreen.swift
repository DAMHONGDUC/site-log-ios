// R3 · Letterhead

import DesignSystem
import Inject
import SwiftUI

struct BrandingScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var company = "Eastline Site Supervision Co."
    @State private var preparedFor = "Riverside Development JSC"
    @State private var footer = "Internal report — not a formal acceptance record"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                BrandingLogoRow()

                DSTextField(String(localized: "reports.branding.company"), text: $company)
                DSTextField(String(localized: "reports.branding.prepared_for"), text: $preparedFor)
                DSTextField(
                    String(localized: "reports.branding.footer"),
                    text: $footer,
                    isMultiline: true
                )
            }
            .padding(DSSpacing.spacing16)
        }
        .background(DSColor.canvas)
        .navigationTitle("reports.branding.your_letterhead")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            Button("reports.branding.save") {
                dismiss()
            }
            .buttonStyle(.sd(.primary))
        }
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        BrandingScreen()
    }
}

private struct BrandingLogoRow: View {
    var body: some View {
        HStack(spacing: DSSpacing.spacing12) {
            Text(verbatim: "EL")
                .modifier(DSTextStyle.section)
                .foregroundStyle(DSColor.onPrimary)
                .frame(width: DSSpacing.spacing64, height: DSSpacing.spacing64)
                .background(
                    DSColor.textPrimary,
                    in: RoundedRectangle(cornerRadius: DSSpacing.spacing12)
                )

            VStack(alignment: .leading) {
                Text(verbatim: "Eastline logo.png")
                    .modifier(DSTextStyle.bodyMedium)
                Text("reports.branding.shown_on_the_cover_and_every_page")
                    .modifier(DSTextStyle.subhead)
                    .foregroundStyle(DSColor.textSecondary)
            }

            Spacer()

            Button("reports.branding.change") {}
                .modifier(DSTextStyle.subheadSemibold)
                .underline()
                .foregroundStyle(DSColor.textPrimary)
        }
    }
}

#Preview("Branding logo row") {
    BrandingLogoRow()
}
