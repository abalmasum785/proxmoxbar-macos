// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProxmoxBar",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "ProxmoxBar", targets: ["ProxmoxBar"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ProxmoxBar",
            dependencies: [],
            path: "Sources",
            resources: [
                .copy("Assets")
            ]
        ),
    ]
)
