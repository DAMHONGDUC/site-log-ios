import DesignSystem
import Inject
import SwiftUI

struct PlanImportScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: DSSpacing.spacing12) {
                RoundedRectangle(cornerRadius: DSSpacing.spacing16)
                    .strokeBorder(
                        DSColor.lineStrong,
                        style: StrokeStyle(
                            lineWidth: DSSpacing.spacing1Point5,
                            dash: [DSSpacing.spacing6, DSSpacing.spacing4]
                        )
                    )
                    .frame(height: DSSpacing.spacing140)
                    .overlay {
                        VStack(spacing: DSSpacing.spacing8) {
                            Image(systemName: "doc.badge.plus")
                            Text("plans.plan_import.pdf_one_sheet_or_many")
                                .modifier(DSTextStyle.subhead)
                        }
                        .foregroundStyle(DSColor.textSecondary)
                    }

                Button {
                    dismiss()
                } label: {
                    Label("plans.plan_import.choose_from_files", systemImage: "folder")
                }
                .buttonStyle(.sd(.primary))

                Button {
                    dismiss()
                } label: {
                    Label("plans.plan_import.photograph_a_printed_sheet", systemImage: "camera")
                }
                .buttonStyle(.sd(.secondary))
            }
            .padding(DSSpacing.spacing16)
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("plans.plan_import.import_a_plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("plans.plan_import.close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
        .enableInjection()
    }
}

#Preview {
    PlanImportScreen()
}
