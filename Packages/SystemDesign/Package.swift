// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "SystemDesign",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "SystemDesign",
            targets: ["SystemDesign"]
        )
    ],
    targets: [
        // Tokens and components only; knows nothing about Domain or feature
        .target(
            name: "SystemDesign",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .testTarget(
            name: "SystemDesignTests",
            dependencies: ["SystemDesign"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
    ]
)
