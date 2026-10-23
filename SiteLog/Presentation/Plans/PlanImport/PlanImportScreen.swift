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
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
                    .frame(height: 140)
                    .overlay {
                        VStack(spacing: DSSpacing.spacing8) {
                            Image(systemName: "doc.badge.plus")
                            Text("plans.planImport.pdfOneSheetOrMany")
                                .modifier(DSTextStyle.subhead)
                        }
                        .foregroundStyle(DSColor.textSecondary)
                    }

                Button {
                    dismiss()
                } label: {
                    Label("plans.planImport.chooseFromFiles", systemImage: "folder")
                }
                .buttonStyle(.sd(.primary))

                Button {
                    dismiss()
                } label: {
                    Label("plans.planImport.photographAPrintedSheet", systemImage: "camera")
                }
                .buttonStyle(.sd(.secondary))
            }
            .padding(DSSpacing.spacing16)
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("plans.planImport.importAPlan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("plans.planImport.close", systemImage: "xmark") {
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
