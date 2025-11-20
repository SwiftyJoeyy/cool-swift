// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Parsing",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Parsing",
            targets: ["Parsing"]
        ),
    ],
    dependencies: [
        Basic.package,
        Lexing.package,
    ],
    targets: [
        .target(
            name: "Parsing",
            dependencies: [
                Basic.target,
                Lexing.target
            ]
        ),
        .testTarget(
            name: "ParsingTests",
            dependencies: ["Parsing"]
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

enum Lexing {
    static let target = Target.Dependency.product(
        name: "Lexing",
        package: "Lexing"
    )
    
    static var package: Package.Dependency {
        return Package.Dependency.package(path: "../Lexing")
    }
}
