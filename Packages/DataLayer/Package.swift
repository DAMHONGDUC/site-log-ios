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
    dependencies: [
        .package(path: "../DomainLayer"),
        .package(path: "../PlatformKit"), 
        .package(path: "../Core"),
    ],
    targets: [
        // Repositories, data sources, models, mappers; system services live in PlatformKit
        .target(
            name: "DataLayer",
            dependencies: ["DomainLayer", "PlatformKit", "Core"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
    ]
)
