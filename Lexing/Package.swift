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
    dependencies: [
        Diagnostics.package
    ],
    targets: [
        .target(
            name: "Lexing",
            dependencies: [
                Diagnostics.target
            ]
        ),
        .testTarget(
            name: "LexingTests",
            dependencies: ["Lexing"],
            resources: [.copy("Resources")]
        ),
    ]
)

enum Diagnostics {
    static let target = Target.Dependency.product(
        name: "Diagnostics",
        package: "Diagnostics"
    )
    
    static var package: Package.Dependency {
        return Package.Dependency.package(path: "../Diagnostics")
    }
}
