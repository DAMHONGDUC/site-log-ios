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
        .navigationTitle("reports.report_builder.report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("reports.report_builder.next") {
                    coordinator.push(ReportsRoute.signature)
                }
                .fontWeight(.semibold)
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            HStack(spacing: DSSpacing.spacing8) {
                Button("reports.report_builder.excel") {}
                    .buttonStyle(.sd(.secondary))
                    .frame(width: DSSpacing.spacing110)

                Button("reports.report_builder.create_pdf") {
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
            Text("reports.report_builder.group_issues_by")
                .modifier(DSTextStyle.footnote)
                .foregroundStyle(DSColor.textSecondary)

            Picker("reports.report_builder.group_issues_by2", selection: $grouping) {
                Text("reports.report_builder.room").tag("Room")
                Text("reports.report_builder.contractor").tag("Contractor")
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal, DSSpacing.spacing16)
    }
}

private struct ReportOption: Identifiable {
    let titleKey: String
    let detail: String?

    var id: String { titleKey }
}

private struct ReportOptionsList: View {
    @State private var included: [String: Bool] = [:]

    private let options: [ReportOption] = [
        ReportOption(titleKey: "reports.options.cover_and_summary", detail: nil),
        ReportOption(
            titleKey: "reports.options.pins_on_each_plan",
            detail: "2 sheets"
        ),
        ReportOption(
            titleKey: "reports.options.checklist_results",
            detail: "3 rooms"
        ),
        ReportOption(
            titleKey: "reports.options.issues_with_photos",
            detail: "7"
        ),
        ReportOption(
            titleKey: "reports.options.before_and_after",
            detail: "4 pairs"
        ),
        ReportOption(titleKey: "reports.options.issues_open_over14_days", detail: nil),
        ReportOption(
            titleKey: "reports.options.signatures",
            detail: "2 people"
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
            DSSectionHeader(title: String(localized: "reports.report_builder.include"))

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
        option.detail
    }

    private var isIncluded: Binding<Bool> {
        Binding(
            get: {
                included[option.id] ?? (option.id != "reports.options.issues_open_over14_days")
            },
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
                    title: String(localized: "reports.report_builder.your_letterhead"),
                    value: "Eastline",
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)

            DSDivider()

            Button {
                coordinator.push(ReportsRoute.signature)
            } label: {
                DSListRow(
                    title: String(localized: "reports.report_builder.signatures"),
                    value: "1 of 2",
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
