// R2 · Report options

import DesignSystem
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
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                VStack(alignment: .leading, spacing: DSSpacing.small) {
                    Text("Group issues by")
                        .font(DSFont.footnote)
                        .foregroundStyle(DSColor.textSecondary)
                    Picker("Group issues by", selection: $grouping) {
                        Text("Room").tag("Room")
                        Text("Contractor").tag("Contractor")
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, DSSpacing.regular)

                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: "Include")

                    ForEach(sections, id: \.title) { section in
                        sectionRow(section)
                        DSDivider()
                    }
                }

                VStack(spacing: 0) {
                    NavigationLink {
                        BrandingView()
                    } label: {
                        DSListRow(title: "Your letterhead", value: "Eastline", showsChevron: true)
                    }
                    .buttonStyle(.plain)

                    DSDivider()

                    NavigationLink {
                        SignaturePadView()
                    } label: {
                        DSListRow(title: "Signatures", value: "1 of 2", showsChevron: true)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
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
            HStack(spacing: DSSpacing.small) {
                Button("Excel") {}
                    .buttonStyle(.ds(.secondary))
                    .frame(width: 110)

                Button("Create PDF") {
                    isPreviewShown = true
                }
                .buttonStyle(.ds(.primary))
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

        return DSListRow(title: section.title, subtitle: section.detail) {
            EmptyView()
        } trailing: {
            Toggle(section.title, isOn: binding)
                .labelsHidden()
                .tint(DSColor.success)
        }
    }
}

#Preview {
    NavigationStack {
        ReportBuilderView()
    }
}
