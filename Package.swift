// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CoolSwift",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        ArgumentParser.package,
        Lexing.package
    ],
    targets: [
        .executableTarget(
            name: "CoolSwift",
            dependencies: [
                ArgumentParser.target,
                Lexing.target
            ]
        ),
    ]
)

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
