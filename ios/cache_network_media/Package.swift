// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "cache_network_media",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "cache-network-media", targets: ["cache_network_media"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "cache_network_media",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
