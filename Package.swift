// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TodoBar",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "TodoBar", targets: ["TodoBar"]),
        .library(name: "TodoBarCore", targets: ["TodoBarCore"])
    ],
    targets: [
        .target(name: "TodoBarCore"),
        .executableTarget(
            name: "TodoBar",
            dependencies: ["TodoBarCore"]
        ),
        .testTarget(
            name: "TodoBarCoreTests",
            dependencies: ["TodoBarCore"]
        )
    ]
)
