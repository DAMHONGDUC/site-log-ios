// R2 · Report options

import SystemDesign
import Inject
import SwiftUI

struct ReportBuilderView: View {
    @ObserveInjection var inject

    @State private var grouping = "Room"
    @State private var included: [String: Bool] = [:]
    @State private var isPreviewShown = false

    private let sections: [(title: String, detail: String?)] = [
        ("Cover and summary", nil),
        ("Pins on each plan", "2 sheets"),
        ("Checklist results", "3 rooms"),
        ("Issues with photos", "7"),
        ("Before and after", "4 pairs"),
        ("Issues open over 14 days", nil),
        ("Signatures", "2 people"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                VStack(alignment: .leading, spacing: SDSpacing.small) {
                    Text("Group issues by")
                        .font(SDFont.footnote)
                        .foregroundStyle(SDColor.textSecondary)
                    Picker("Group issues by", selection: $grouping) {
                        Text("Room").tag("Room")
                        Text("Contractor").tag("Contractor")
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, SDSpacing.regular)

                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    SDSectionHeader(title: "Include")

                    ForEach(sections, id: \.title) { section in
                        sectionRow(section)
                        SDDivider()
                    }
                }

                VStack(spacing: 0) {
                    NavigationLink {
                        BrandingView()
                    } label: {
                        SDListRow(title: "Your letterhead", value: "Eastline", showsChevron: true)
                    }
                    .buttonStyle(.plain)

                    SDDivider()

                    NavigationLink {
                        SignaturePadView()
                    } label: {
                        SDListRow(title: "Signatures", value: "1 of 2", showsChevron: true)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, SDSpacing.small)
        }
        .background(SDColor.canvas)
        .navigationTitle("Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Next") {
                    SignaturePadView()
                }
                .fontWeight(.semibold)
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .bottomDock {
            HStack(spacing: SDSpacing.small) {
                Button("Excel") {}
                    .buttonStyle(.sd(.secondary))
                    .frame(width: 110)

                Button("Create PDF") {
                    isPreviewShown = true
                }
                .buttonStyle(.sd(.primary))
            }
        }
        .navigationDestination(isPresented: $isPreviewShown) {
            PDFPreviewView()
        }
        .enableInjection()
    }

    private func sectionRow(_ section: (title: String, detail: String?)) -> some View {
        let defaultValue = section.title != "Issues open over 14 days"
        let binding = Binding<Bool>(
            get: { included[section.title] ?? defaultValue },
            set: { included[section.title] = $0 }
        )

        return SDListRow(title: section.title, subtitle: section.detail) {
            EmptyView()
        } trailing: {
            Toggle(section.title, isOn: binding)
                .labelsHidden()
                .tint(SDColor.success)
        }
    }
}

#Preview {
    NavigationStack {
        ReportBuilderView()
    }
}
