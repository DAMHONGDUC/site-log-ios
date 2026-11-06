// P4 · New walkthrough

import DesignSystem
import Inject
import SwiftUI

struct StartSessionScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var inspector = FakeData.inspector
    @State private var weather = "projects.start_session.weather.sunny"
    @State private var note = ""

    private let weatherOptions: [(titleKey: String, icon: String)] = [
        ("projects.start_session.weather.sunny", "sun.max"),
        ("projects.start_session.weather.overcast", "cloud"),
        ("projects.start_session.weather.rain", "cloud.rain"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.spacing16) {
                    DSTextField(
                        String(localized: "projects.start_session.inspector"),
                        text: $inspector
                    )

                    VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
                        Text("projects.start_session.weather")
                            .modifier(DSTextStyle.footnote)
                            .foregroundStyle(DSColor.textSecondary)
                        HStack(spacing: DSSpacing.spacing8) {
                            ForEach(weatherOptions, id: \.titleKey) { option in
                                DSChip(
                                    title: NSLocalizedString(option.titleKey, comment: ""),
                                    systemImage: option.icon,
                                    isSelected: weather == option.titleKey
                                ) {
                                    weather = option.titleKey
                                }
                            }
                        }
                    }

                    DSTextField(
                        String(localized: "projects.start_session.note_for_the_report"),
                        placeholder: String(
                            localized: "projects.start_session.session_name_placeholder"
                        ),
                        text: $note,
                        isMultiline: true
                    )

                    HStack(alignment: .top, spacing: DSSpacing.spacing8) {
                        DSStatusMarker(kind: .major)
                        Text(
                            "projects.start_session.pending_issues_note"
                        )
                        .modifier(DSTextStyle.subhead)
                    }
                }
                .padding(DSSpacing.spacing16)
            }
            .navigationTitle("projects.start_session.new_walkthrough")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("projects.start_session.close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .bottomDock {
                Button("projects.start_session.start") {
                    dismiss()
                }
                .buttonStyle(.sd(.primary))
            }
        }
        .enableInjection()
    }
}

#Preview {
    StartSessionScreen()
}
