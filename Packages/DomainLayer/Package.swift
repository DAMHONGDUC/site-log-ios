// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "DomainLayer",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "DomainLayer",
            targets: ["DomainLayer"]
        )
    ],
    targets: [
        // Entities, repository protocols, use cases. Foundation only
        .target(
            name: "DomainLayer",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
    ]
)
