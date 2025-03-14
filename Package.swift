// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LumaKit",
    platforms: [.iOS(.v15), .macOS(.v10_15)],
    products: [
        .library(name: "LumaKit", targets: ["LumaKit"]),
        .library(name: "LumaKitShare", targets: ["LumaKitShare"])
    ],
    dependencies: [
        .package(url: "https://github.com/disabled/GenericModule", branch: "master"),
        .package(url: "https://github.com/airbnb/lottie-ios", branch: "master"),
        .package(url: "https://github.com/tiktok/tiktok-opensdk-ios", .upToNextMajor(from: "2.5.0"))
    ],
    targets: [
        .target(
            name: "LumaKit",
            dependencies: [
                .product(name: "GenericModule", package: "GenericModule"),
                .product(name: "Lottie", package: "lottie-ios")
            ],
            path: "Sources/LumaKit",
            resources: []),
        .target(
            name: "LumaKitShare",
            dependencies: [
                .targetItem(name: "LumaKit", condition: nil),
                .product(name: "GenericModule", package: "GenericModule"),
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "TikTokOpenSDKCore", package: "tiktok-opensdk-ios"),
                .product(name: "TikTokOpenShareSDK", package: "tiktok-opensdk-ios")
            ],
            path: "Sources/LumaKitShare",
            resources: [])
    ]
)
