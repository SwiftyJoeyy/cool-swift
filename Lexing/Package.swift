// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Lexing",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Lexing",
            targets: ["Lexing"]
        ),
    ],
    targets: [
        .target(
            name: "Lexing"
        ),
        .testTarget(
            name: "LexingTests",
            dependencies: ["Lexing"]
        ),
    ]
)
