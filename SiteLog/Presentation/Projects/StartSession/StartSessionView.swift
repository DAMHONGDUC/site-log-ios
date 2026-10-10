// P4 · New walkthrough

import SystemDesign
import Inject
import SwiftUI

struct StartSessionView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var inspector = FakeData.inspector
    @State private var weather = "Sunny"
    @State private var note = ""

    private let weatherOptions: [(title: String, icon: String)] = [
        ("Sunny", "sun.max"),
        ("Overcast", "cloud"),
        ("Rain", "cloud.rain"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SDSpacing.regular) {
                    SDTextField("Inspector", text: $inspector)

                    VStack(alignment: .leading, spacing: SDSpacing.small) {
                        Text("Weather")
                            .font(SDFont.footnote)
                            .foregroundStyle(SDColor.textSecondary)
                        HStack(spacing: SDSpacing.small) {
                            ForEach(weatherOptions, id: \.title) { option in
                                SDChip(title: option.title, systemImage: option.icon, isSelected: weather == option.title) {
                                    weather = option.title
                                }
                            }
                        }
                    }

                    SDTextField(
                        "Note for the report",
                        placeholder: "e.g. finishing check, levels 7–9",
                        text: $note,
                        isMultiline: true
                    )

                    HStack(alignment: .top, spacing: SDSpacing.small) {
                        SDStatusMarker(kind: .major)
                        Text("14 issues from 12 Aug will be waiting in their rooms for you to re-check.")
                            .font(SDFont.subhead)
                    }
                }
                .padding(SDSpacing.regular)
            }
            .navigationTitle("New walkthrough")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .bottomDock {
                Button("Start") {
                    dismiss()
                }
                .buttonStyle(.sd(.primary))
            }
        }
        .enableInjection()
    }
}

#Preview {
    StartSessionView()
}
