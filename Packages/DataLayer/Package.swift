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
        .package(path: "../Core"),
    ],
    targets: [
        // Repositories, DTOs, mappers, fakes and data sources (Local, Remote)
        .target(
            name: "DataLayer",
            dependencies: ["DomainLayer", "Core"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
    ]
)
