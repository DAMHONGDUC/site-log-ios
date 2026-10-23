// R2 · Report options

import DesignSystem
import Inject
import SwiftUI

struct ReportBuilderScreen: View {
    @ObserveInjection var inject
    @Environment(\.coordinator) private var coordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                ReportGroupingPicker()
                ReportOptionsList()
                ReportMetadataLinks()
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("reports.reportBuilder.report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("reports.reportBuilder.next") {
                    coordinator.push(ReportsRoute.signature)
                }
                .fontWeight(.semibold)
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            HStack(spacing: DSSpacing.spacing8) {
                Button("reports.reportBuilder.excel") {}
                    .buttonStyle(.sd(.secondary))
                    .frame(width: DSSpacing.spacing110)

                Button("reports.reportBuilder.createPdf") {
                    coordinator.push(ReportsRoute.pdfPreview)
                }
                .buttonStyle(.sd(.primary))
            }
        }
        .enableInjection()
    }
}

private struct ReportGroupingPicker: View {
    @State private var grouping = "Room"

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing8) {
            Text("reports.reportBuilder.groupIssuesBy")
                .modifier(DSTextStyle.footnote)
                .foregroundStyle(DSColor.textSecondary)

            Picker("reports.reportBuilder.groupIssuesBy2", selection: $grouping) {
                Text("reports.reportBuilder.room").tag("Room")
                Text("reports.reportBuilder.contractor").tag("Contractor")
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal, DSSpacing.spacing16)
    }
}

private struct ReportOption: Identifiable {
    let titleKey: String
    let detailKey: String?

    var id: String { titleKey }
}

private struct ReportOptionsList: View {
    @State private var included: [String: Bool] = [:]

    private let options: [ReportOption] = [
        ReportOption(titleKey: "reports.options.coverAndSummary", detailKey: nil),
        ReportOption(
            titleKey: "reports.options.pinsOnEachPlan",
            detailKey: "reports.options.twoSheets"
        ),
        ReportOption(
            titleKey: "reports.options.checklistResults",
            detailKey: "reports.options.threeRooms"
        ),
        ReportOption(
            titleKey: "reports.options.issuesWithPhotos",
            detailKey: "reports.options.seven"
        ),
        ReportOption(
            titleKey: "reports.options.beforeAndAfter",
            detailKey: "reports.options.fourPairs"
        ),
        ReportOption(titleKey: "reports.options.issuesOpenOver14Days", detailKey: nil),
        ReportOption(
            titleKey: "reports.options.signatures",
            detailKey: "reports.options.twoPeople"
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
            DSSectionHeader(title: String(localized: "reports.reportBuilder.include"))

            ForEach(options) { option in
                ReportOptionRow(option: option, included: $included)
                DSDivider()
            }
        }
    }
}

private struct ReportOptionRow: View {
    let option: ReportOption
    @Binding var included: [String: Bool]

    private var title: String {
        NSLocalizedString(option.titleKey, comment: "")
    }

    private var detail: String? {
        guard let detailKey = option.detailKey else { return nil }
        return NSLocalizedString(detailKey, comment: "")
    }

    private var isIncluded: Binding<Bool> {
        Binding(
            get: { included[option.id] ?? (option.id != "reports.options.issuesOpenOver14Days") },
            set: { included[option.id] = $0 }
        )
    }

    var body: some View {
        DSListRow(title: title, subtitle: detail) {
            EmptyView()
        } trailing: {
            Toggle(title, isOn: isIncluded)
                .labelsHidden()
                .tint(DSColor.success)
        }
    }
}

private struct ReportMetadataLinks: View {
    @Environment(\.coordinator) private var coordinator

    var body: some View {
        VStack(spacing: DSSpacing.spacing0) {
            Button {
                coordinator.push(ReportsRoute.branding)
            } label: {
                DSListRow(
                    title: String(localized: "reports.reportBuilder.yourLetterhead"),
                    value: String(localized: "reports.reportBuilder.eastline"),
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)

            DSDivider()

            Button {
                coordinator.push(ReportsRoute.signature)
            } label: {
                DSListRow(
                    title: String(localized: "reports.reportBuilder.signatures"),
                    value: String(localized: "reports.reportBuilder.oneOfTwo"),
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        ReportBuilderScreen()
    }
}

#Preview("Grouping picker") {
    ReportGroupingPicker()
}

#Preview("Report options") {
    ReportOptionsList()
}

#Preview("Metadata links") {
    ReportMetadataLinks()
}
