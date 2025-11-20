// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CoolSwift",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        Basic.package,
        ArgumentParser.package,
        Lexer.package,
        Parser.package
    ],
    targets: [
        .executableTarget(
            name: "CoolSwift",
            dependencies: [
                Basic.target,
                ArgumentParser.target,
                Lexer.target,
                Parser.target
            ]
        ),
    ]
)

enum Basic {
    static let target = Target.Dependency.product(
        name: "Basic",
        package: "Basic"
    )

    static var package: Package.Dependency {
        return Package.Dependency.package(path: "Basic")
    }
}

enum ArgumentParser {
    static let target = Target.Dependency.product(
        name: "ArgumentParser",
        package: "swift-argument-parser"
    )

    static var package: Package.Dependency {
        return Package.Dependency.package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.2.0"
        )
    }
}

enum Lexer {
    static let target = Target.Dependency.product(
        name: "Lexer",
        package: "Lexer"
    )

    static var package: Package.Dependency {
        return Package.Dependency.package(path: "Lexer")
    }
}

enum Parser {
    static let target = Target.Dependency.product(
        name: "Parser",
        package: "Parser"
    )

    static var package: Package.Dependency {
        return Package.Dependency.package(path: "Parser")
    }
}
