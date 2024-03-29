// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LumaKit",
    platforms: [.iOS(.v15), .macOS(.v10_15)],
    products: [
        .library(name: "LumaKit", targets: ["LumaKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/disabled/GenericModule", branch: "master"),
        .package(url: "https://github.com/airbnb/lottie-ios", branch: "master")
    ],
    targets: [
        .target(
            name: "LumaKit",
            dependencies: [
                .product(name: "GenericModule", package: "GenericModule"),
                .product(name: "Lottie", package: "lottie-ios")
            ],
            path: "Sources/LumaKit",
            resources: [])
    ]
)
