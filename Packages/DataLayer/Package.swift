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
        .package(path: "../Infrastructure"),
        .package(path: "../Core"),
    ],
    targets: [
        // Repositories, data sources (Local, Remote), models (Local, Remote), mappers
        .target(
            name: "DataLayer",
            dependencies: ["DomainLayer", "Infrastructure", "Core"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
    ]
)
