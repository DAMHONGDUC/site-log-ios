// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Infrastructure",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Infrastructure",
            targets: ["Infrastructure"]
        )
    ],
    dependencies: [
        .package(path: "../Core"),
    ],
    targets: [
        // System services: permissions, camera, Bluetooth, Face ID… Never DomainLayer
        .target(
            name: "Infrastructure",
            dependencies: ["Core"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
    ]
)
