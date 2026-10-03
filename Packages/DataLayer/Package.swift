// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "DataLayer",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "DataLayer",
            targets: ["DataLayer"]
        )
    ],
    // DataLayer implements the protocols that Domain declares
    dependencies: [
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "DataLayer",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .testTarget(
            name: "DataLayerTests",
            dependencies: ["DataLayer"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
    ]
)
