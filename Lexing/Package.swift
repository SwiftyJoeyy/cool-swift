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
        Basic.package,
        Diagnostics.package
    ],
    targets: [
        .target(
            name: "Lexing",
            dependencies: [
                Basic.target,
                Diagnostics.target
            ]
        ),
        .testTarget(
            name: "LexingTests",
            dependencies: ["Lexing"],
            resources: [.copy("IntegrationTests/Resources")]
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

enum Basic {
    static let target = Target.Dependency.product(
        name: "Basic",
        package: "Basic"
    )
    
    static var package: Package.Dependency {
        return Package.Dependency.package(path: "../Basic")
    }
}
