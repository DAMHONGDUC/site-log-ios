// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Core",
            targets: ["Core"]
        )
    ],
    targets: [
        // App-wide helpers: logger, clock. Knows nothing about features
        .target(
            name: "Core",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
    ]
)
