// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "PlatformKit",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "PlatformKit",
            targets: ["PlatformKit"]
        )
    ],
    dependencies: [
        .package(path: "../Core"),
    ],
    targets: [
        // System services: permissions, camera, Bluetooth, Face ID… Never DomainLayer
        .target(
            name: "PlatformKit",
            dependencies: ["Core"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
    ]
)
