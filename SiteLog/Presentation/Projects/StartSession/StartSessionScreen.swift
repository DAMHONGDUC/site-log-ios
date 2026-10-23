// P4 · New walkthrough

import DesignSystem
import Inject
import SwiftUI

struct StartSessionScreen: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss

    @State private var inspector = FakeData.inspector
    @State private var weather = "projects.startSession.weather.sunny"
    @State private var note = ""

    private let weatherOptions: [(titleKey: String, icon: String)] = [
        ("projects.startSession.weather.sunny", "sun.max"),
        ("projects.startSession.weather.overcast", "cloud"),
        ("projects.startSession.weather.rain", "cloud.rain"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.spacing16) {
                    DSTextField(
                        String(localized: "projects.startSession.inspector"),
                        text: $inspector
                    )

                    VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
                        Text("projects.startSession.weather")
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
                        String(localized: "projects.startSession.noteForTheReport"),
                        placeholder: String(
                            localized: "projects.startSession.eGFinishingCheckLevels79"
                        ),
                        text: $note,
                        isMultiline: true
                    )

                    HStack(alignment: .top, spacing: DSSpacing.spacing8) {
                        DSStatusMarker(kind: .major)
                        Text(
                            "projects.startSession.14IssuesFrom12AugWillBeWaitingInTheirRoomsForYouToReCheck"
                        )
                        .modifier(DSTextStyle.subhead)
                    }
                }
                .padding(DSSpacing.spacing16)
            }
            .navigationTitle("projects.startSession.newWalkthrough")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("projects.startSession.close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .bottomDock {
                Button("projects.startSession.start") {
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
