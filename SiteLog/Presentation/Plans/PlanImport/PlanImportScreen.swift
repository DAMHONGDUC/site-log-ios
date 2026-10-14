import DesignSystem
import Inject
import SwiftUI

struct PlanImportScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: DSSpacing.medium) {
                RoundedRectangle(cornerRadius: DSRadius.large)
                    .strokeBorder(
                        DSColor.lineStrong,
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
                    .frame(height: 140)
                    .overlay {
                        VStack(spacing: DSSpacing.small) {
                            Image(systemName: "doc.badge.plus")
                            Text("PDF, one sheet or many")
                                .font(DSFont.subhead)
                        }
                        .foregroundStyle(DSColor.textSecondary)
                    }

                Button {
                    dismiss()
                } label: {
                    Label("Choose from Files", systemImage: "folder")
                }
                .buttonStyle(.sd(.primary))

                Button {
                    dismiss()
                } label: {
                    Label("Photograph a printed sheet", systemImage: "camera")
                }
                .buttonStyle(.sd(.secondary))
            }
            .padding(DSSpacing.regular)
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("Import a plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "xmark") {
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
