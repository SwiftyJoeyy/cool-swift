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
    dependencies: [
        Basic.package
    ],
    targets: [
        .target(
            name: "Diagnostics",
            dependencies: [Basic.target]
        ),
        .testTarget(
            name: "DiagnosticsTests",
            dependencies: ["Diagnostics"]
        ),
    ]
)

enum Basic {
    static let target = Target.Dependency.product(
        name: "Basic",
        package: "Basic"
    )
    
    static var package: Package.Dependency {
        return Package.Dependency.package(path: "../Basic")
    }
}
