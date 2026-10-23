// S2 · Laser meter

import DesignSystem
import Inject
import SwiftUI

struct DevicesScreen: View {
    @ObserveInjection var inject

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.spacing24) {
                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(title: String(localized: "settings.devices.myDevices"))
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

                VStack(alignment: .leading, spacing: DSSpacing.spacing4) {
                    DSSectionHeader(
                        title: String(localized: "settings.devices.nearby"),
                        trailing: String(localized: "settings.devices.searching")
                    )
                    ForEach(FakeData.nearbyDevices) { device in
                        DSListRow(title: device.name, subtitle: device.detail) {
                            EmptyView()
                        } trailing: {
                            Button("settings.devices.pair") {}
                                .buttonStyle(.sd(.secondary, small: true))
                        }
                        DSDivider()
                    }
                }

                Text(
                    "settings.devices.theCameraNeverWaitsForTheMeterIfItDisconnectsYouKeepShootingAndWeReconnectQuietly"
                )
                .modifier(DSTextStyle.footnote)
                .foregroundStyle(DSColor.textSecondary)
                .padding(.horizontal, DSSpacing.spacing16)
            }
            .padding(.vertical, DSSpacing.spacing8)
        }
        .background(DSColor.canvas)
        .navigationTitle("settings.devices.laserMeter")
        .navigationBarTitleDisplayMode(.inline)
        .enableInjection()
    }
}

#Preview {
    NavigationStack {
        DevicesScreen()
    }
}
