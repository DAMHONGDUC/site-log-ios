//
//  DevicesView.swift
//  SiteLog
//
//  S2 · Laser meter: paired devices + nearby ones (fake BLE scan).
//

import DesignSystem
import Inject
import SwiftUI

struct DevicesView: View {
    @ObserveInjection var inject

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: "My devices")
                    ForEach(FakeData.myDevices) { device in
                        DSListRow(title: device.name, subtitle: device.detail) {
                            EmptyView()
                        } trailing: {
                            if device.isConnected {
                                DSStatusMarker(kind: .resolved)
                            }
                        }
                        DSDivider()
                    }
                }

                VStack(alignment: .leading, spacing: DSSpacing.tiny) {
                    DSSectionHeader(title: "Nearby", trailing: "Searching…")
                    ForEach(FakeData.nearbyDevices) { device in
                        DSListRow(title: device.name, subtitle: device.detail) {
                            EmptyView()
                        } trailing: {
                            Button("Pair") {}
                                .buttonStyle(.ds(.secondary, small: true))
                        }
                        DSDivider()
                    }
                }

                Text("The camera never waits for the meter. If it disconnects, you keep shooting and we reconnect quietly.")
                    .font(DSFont.footnote)
                    .foregroundStyle(DSColor.textSecondary)
                    .padding(.horizontal, DSSpacing.regular)
            }
            .padding(.vertical, DSSpacing.small)
        }
        .background(DSColor.canvas)
        .navigationTitle("Laser meter")
        .navigationBarTitleDisplayMode(.inline)
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        DevicesView()
    }
}
