// S2 · Laser meter

import SystemDesign
import Inject
import SwiftUI

struct DevicesView: View {
    @ObserveInjection var inject

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.large) {
                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    SDSectionHeader(title: "My devices")
                    ForEach(FakeData.myDevices) { device in
                        SDListRow(title: device.name, subtitle: device.detail) {
                            EmptyView()
                        } trailing: {
                            if device.isConnected {
                                SDStatusMarker(kind: .resolved)
                            }
                        }
                        SDDivider()
                    }
                }

                VStack(alignment: .leading, spacing: SDSpacing.tiny) {
                    SDSectionHeader(title: "Nearby", trailing: "Searching…")
                    ForEach(FakeData.nearbyDevices) { device in
                        SDListRow(title: device.name, subtitle: device.detail) {
                            EmptyView()
                        } trailing: {
                            Button("Pair") {}
                                .buttonStyle(.sd(.secondary, small: true))
                        }
                        SDDivider()
                    }
                }

                Text("The camera never waits for the meter. If it disconnects, you keep shooting and we reconnect quietly.")
                    .font(SDFont.footnote)
                    .foregroundStyle(SDColor.textSecondary)
                    .padding(.horizontal, SDSpacing.regular)
            }
            .padding(.vertical, SDSpacing.small)
        }
        .background(SDColor.canvas)
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
