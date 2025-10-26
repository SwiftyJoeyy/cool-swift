// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Diagnostics",
    products: [
        .library(
            name: "Diagnostics",
            targets: ["Diagnostics"]
        ),
    ],
    targets: [
        .target(
            name: "Diagnostics"
        ),
        .testTarget(
            name: "DiagnosticsTests",
            dependencies: ["Diagnostics"]
        ),
    ]
)
