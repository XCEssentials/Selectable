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
    targets: [
        .target(
            name: "XCESelectable",
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