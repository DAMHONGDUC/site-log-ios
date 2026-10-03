// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        // iOS only: the app's deployment target
        .library(
            name: "Domain",
            targets: ["Domain"]
        )
    ],
    targets: [
        // Domain imports Foundation only: no other package, no Apple UI framework
        .target(
            name: "Domain",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
    ]
)
