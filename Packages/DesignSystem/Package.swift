// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]
        )
    ],
    targets: [
        // Tokens and components only; knows nothing about Domain or feature
        .target(
            name: "DesignSystem",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
    ]
)
