//
//  StampPreviewView.swift
//  SiteLog
//
//  M2 · Share a stamped photo: the stamp strip + what it shows.
//

import DesignSystem
import Inject
import SwiftUI

struct StampPreviewView: View {
    @ObserveInjection var inject

    @State private var showsDate = true
    @State private var showsRoom = true
    @State private var showsMarkup = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                SitePhoto(variant: 0, showsCrack: true)
                    .frame(height: 300)
                    .overlay(alignment: .bottom) {
                        stampStrip
                    }

                Text("Time checked against the network (within 2 s) and GPS (±6 m), so the stamp can be trusted.")
                    .font(DSFont.footnote)
                    .foregroundStyle(DSColor.textSecondary)
                    .padding(.horizontal, DSSpacing.regular)

                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: "Stamp shows")
                    toggleRow("Date and time", isOn: $showsDate)
                    DSDivider()
                    toggleRow("Project and room", isOn: $showsRoom)
                    DSDivider()
                    toggleRow("My markup", isOn: $showsMarkup)
                }
            }
        }
        .background(DSColor.canvas)
        .navigationTitle("Share photo")
        .navigationBarTitleDisplayMode(.inline)
        .bottomDock {
            ShareLink(item: "Verify at sitelog.app/v/7F3K-92QD") {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.ds(.primary))
        }
        .enableInjection()
    }

    private var stampStrip: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showsDate {
                Text("30 Sep 2026 10:42:18 +07 · Riverside Tower B")
            }
            if showsRoom {
                Text("Level 7 › 7A › Living room · 10.7297, 106.7215")
            }
            Text("Verify at sitelog.app/v/7F3K-92QD")
        }
        .font(DSFont.code)
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
        .background(Color.black.opacity(0.72))
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .tint(DSColor.success)
            .frame(minHeight: DSSize.rowMinHeight)
            .padding(.horizontal, DSSpacing.regular)
    }
}

#Preview {
    NavigationStack {
        StampPreviewView()
    }
}
