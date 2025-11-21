// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CoolSwift",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        AST.product,
        Basic.product,
        Diagnostics.product,
        Lexer.product,
        Parser.product
    ],
    dependencies: [
        ArgumentParser.package
    ],
    targets: [
        AST.target,
        Basic.target,
        Diagnostics.target,
        
        Lexer.target,
        Lexer.tests,
        
        Parser.target,
        Parser.tests,
        
        .executableTarget(
            name: "CoolSwift",
            dependencies: [
                ArgumentParser.dependency,
                Lexer.dependency
            ]
        ),
    ]
)

enum ArgumentParser {
    static let dependency = Target.Dependency.product(
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

enum AST {
    static let dependency: Target.Dependency = "AST"
    static var product: Product {
        .library(name: "AST", targets: ["AST"])
    }
    static var target: Target {
        .target(name: "AST", dependencies: [Basic.dependency])
    }
}

enum Basic {
    static let dependency: Target.Dependency = "Basic"
    static var product: Product {
        .library(name: "Basic", targets: ["Basic"])
    }
    static var target: Target {
        Target.target(name: "Basic")
    }
}

enum Diagnostics {
    static let dependency: Target.Dependency = "Diagnostics"
    static var product: Product {
        .library(name: "Diagnostics", targets: ["Diagnostics"])
    }
    static var target: Target {
        .target(name: "Diagnostics", dependencies: [Basic.dependency])
    }
}

enum Lexer {
    static let dependency: Target.Dependency = "Lexer"
    static var product: Product {
        .library(name: "Lexer", targets: ["Lexer"])
    }
    static var target: Target {
        .target(
            name: "Lexer",
            dependencies: [Basic.dependency, Diagnostics.dependency]
        )
    }
    static var tests: Target {
        .testTarget(
            name: "LexerTests",
            dependencies: [Lexer.dependency],
            resources: [.copy("IntegrationTests/Resources")]
        )
    }
}

enum Parser {
    static let dependency: Target.Dependency = "Parser"
    static var product: Product {
        .library(name: "Parser", targets: ["Parser"])
    }
    static var target: Target {
        .target(
            name: "Parser",
            dependencies: [
                AST.dependency,
                Basic.dependency,
                Diagnostics.dependency
            ]
        )
    }
    static var tests: Target {
        .testTarget(name: "ParserTests", dependencies: [Parser.dependency])
    }
}
