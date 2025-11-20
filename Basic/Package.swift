// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Basic",
    products: [
        .library(
            name: "Basic",
            targets: ["Basic"]
        ),
    ],
    targets: [
        .target(
            name: "Basic"
        ),
        .testTarget(
            name: "BasicTests",
            dependencies: ["Basic"]
        ),
    ]
)
