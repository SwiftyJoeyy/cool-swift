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
        Lexing.package,
        Parsing.package
    ],
    targets: [
        .executableTarget(
            name: "CoolSwift",
            dependencies: [
                Basic.target,
                ArgumentParser.target,
                Lexing.target,
                Parsing.target
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

enum Lexing {
    static let target = Target.Dependency.product(
        name: "Lexing",
        package: "Lexing"
    )
    
    static var package: Package.Dependency {
        return Package.Dependency.package(path: "Lexing")
    }
}

enum Parsing {
    static let target = Target.Dependency.product(
        name: "Parsing",
        package: "Parsing"
    )
    
    static var package: Package.Dependency {
        return Package.Dependency.package(path: "Parsing")
    }
}
