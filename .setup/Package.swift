// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SelectableSetup",
    platforms: [
        .macOS(.v10_11),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/PathKit", from: "1.0.0"),
        .package(url: "https://github.com/XCEssentials/RepoConfigurator", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "SelectableSetup",
            dependencies: ["XCERepoConfigurator", "PathKit"],
            path: ".",
            sources: ["main.swift"]
        )
    ]
)
