//
//  StartSessionView.swift
//  SiteLog
//
//  P4 · New walkthrough sheet: inspector, weather, note.
//

import DesignSystem
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
                VStack(alignment: .leading, spacing: DSSpacing.regular) {
                    DSTextField("Inspector", text: $inspector)

                    VStack(alignment: .leading, spacing: DSSpacing.small) {
                        Text("Weather")
                            .font(DSFont.footnote)
                            .foregroundStyle(DSColor.textSecondary)
                        HStack(spacing: DSSpacing.small) {
                            ForEach(weatherOptions, id: \.title) { option in
                                DSChip(title: option.title, systemImage: option.icon, isSelected: weather == option.title) {
                                    weather = option.title
                                }
                            }
                        }
                    }

                    DSTextField(
                        "Note for the report",
                        placeholder: "e.g. finishing check, levels 7–9",
                        text: $note,
                        isMultiline: true
                    )

                    HStack(alignment: .top, spacing: DSSpacing.small) {
                        DSStatusMarker(kind: .major)
                        Text("14 issues from 12 Aug will be waiting in their rooms for you to re-check.")
                            .font(DSFont.subhead)
                    }
                }
                .padding(DSSpacing.regular)
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
                .buttonStyle(.ds(.primary))
            }
        }
        .enableInjection()
    }
}

#Preview {
    StartSessionView()
}
