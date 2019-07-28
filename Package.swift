// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "XCESelectable",
    products: [
        .library(
            name: "XCESelectable",
            targets: [
                "XCESelectable"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/XCEssentials/ArrayExt", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "XCESelectable",
            dependencies: [
                "XCEArrayExt"
            ],
            path: "Sources/Core"
        ),
        .testTarget(
            name: "XCESelectableAllTests",
            dependencies: [
                "XCESelectable"
            ],
            path: "Tests/AllTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)