// swift-tools-version: 6.0
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

import PackageDescription

let package = Package(
    name: "swift-dotenv",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "DotEnv", targets: ["DotEnv"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin.git", from: "1.4.0")
    ],
    targets: [
        .target(name: "DotEnv"),
        .testTarget(
            name: "DotEnvTests",
            dependencies: ["DotEnv"],
            resources: [.copy("../Vectors")]
        )
    ]
)
