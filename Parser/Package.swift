// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Parser",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Parser",
            targets: ["Parser"]
        ),
    ],
    dependencies: [
        Basic.package,
        Lexer.package,
    ],
    targets: [
        .target(
            name: "Parser",
            dependencies: [
                Basic.target,
                Lexer.target
            ]
        ),
        .testTarget(
            name: "ParserTests",
            dependencies: ["Parser"]
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

enum Lexer {
    static let target = Target.Dependency.product(
        name: "Lexer",
        package: "Lexer"
    )

    static var package: Package.Dependency {
        return Package.Dependency.package(path: "../Lexer")
    }
}
