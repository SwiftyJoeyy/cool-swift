// swift-tools-version: 6.4

import PackageDescription

let upcomingFeatures: [SwiftSetting] = [
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault")
]

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
        Parser.product,
        Sema.product,
        CodeGen.product,
        CoreModule.product
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
        
        Sema.target,
        Sema.tests,
        
        CodeGen.target,
        CodeGen.tests,
        
        CoreModule.target,
        CoreModule.embedder,
        CoreModule.embedPlugin,
        
        TestSupport.target,
        
        .executableTarget(
            name: "CoolSwift",
            dependencies: [
                ArgumentParser.dependency,
                Basic.dependency,
                Diagnostics.dependency,
                Lexer.dependency,
                Parser.dependency,
                Sema.dependency,
                CodeGen.dependency,
                CoreModule.dependency
            ],
            swiftSettings: upcomingFeatures
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

enum LLVMBindings {
    static var swiftSettings: [SwiftSetting]? {
        let llvmHeaderPath = "/Users/joemaghzal/Documents/swift-project/llvm-project/llvm/include"
        let llvmModuleMapPath = "\(llvmHeaderPath)/module.modulemap"
        let llvmGeneratedHeaderPath = "/Users/joemaghzal/Documents/swift-project/build/Ninja-RelWithDebInfoAssert+swift-DebugAssert/llvm-macosx-arm64/include"
        return [
            .interoperabilityMode(.Cxx),
            .unsafeFlags([
                "-I\(llvmHeaderPath)",
                "-Xcc", "-I\(llvmHeaderPath)",
                "-I\(llvmGeneratedHeaderPath)",
                "-Xcc", "-I\(llvmGeneratedHeaderPath)",
                "-Xcc", "-fmodule-map-file=\(llvmModuleMapPath)",
            ]),
        ]
    }
    static let dependency = Target.Dependency.product(
        name: "SwiftLLVM_Utils",
        package: "swift-llvm-bindings-llvm.org-main"
    )
    
    static var package: Package.Dependency {
        return Package.Dependency.package(
            path: "../swift-llvm-bindings-llvm.org-main"
        )
    }
}

enum AST {
    static let dependency: Target.Dependency = "AST"
    static var product: Product {
        .library(name: "AST", targets: ["AST"])
    }
    static var target: Target {
        .target(
            name: "AST",
            dependencies: [Basic.dependency],
            swiftSettings: upcomingFeatures
        )
    }
}

enum Basic {
    static let dependency: Target.Dependency = "Basic"
    static var product: Product {
        .library(name: "Basic", targets: ["Basic"])
    }
    static var target: Target {
        Target.target(name: "Basic", swiftSettings: upcomingFeatures)
    }
}

enum Diagnostics {
    static let dependency: Target.Dependency = "Diagnostics"
    static var product: Product {
        .library(name: "Diagnostics", targets: ["Diagnostics"])
    }
    static var target: Target {
        .target(
            name: "Diagnostics",
            dependencies: [Basic.dependency],
            swiftSettings: upcomingFeatures
        )
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
            dependencies: [Basic.dependency, Diagnostics.dependency],
            swiftSettings: upcomingFeatures
        )
    }
    static var tests: Target {
        .testTarget(
            name: "LexerTests",
            dependencies: [Lexer.dependency],
            resources: [.copy("IntegrationTests/Resources")],
            swiftSettings: upcomingFeatures
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
                Diagnostics.dependency,
                Lexer.dependency
            ],
            swiftSettings: upcomingFeatures
        )
    }
    static var tests: Target {
        .testTarget(
            name: "ParserTests",
            dependencies: [
                Parser.dependency,
                TestSupport.dependency
            ],
            resources: [.copy("IntegrationTests/Resources")],
            swiftSettings: upcomingFeatures
        )
    }
}

enum Sema {
    static let dependency: Target.Dependency = "Sema"
    static var product: Product {
        .library(name: "Sema", targets: ["Sema"])
    }
    static var target: Target {
        .target(
            name: "Sema",
            dependencies: [
                AST.dependency,
                Basic.dependency,
                Diagnostics.dependency,
                Parser.dependency
            ],
            swiftSettings: upcomingFeatures
        )
    }
    static var tests: Target {
        .testTarget(
            name: "SemaTests",
            dependencies: [
                Sema.dependency,
                TestSupport.dependency,
                CoreModule.dependency
            ],
            resources: [.copy("Resources")],
            swiftSettings: upcomingFeatures
        )
    }
}

enum TestSupport {
    static let dependency: Target.Dependency = "TestSupport"
    static var target: Target {
        .target(
            name: "TestSupport",
            dependencies: [
                Diagnostics.dependency,
                Lexer.dependency,
                Parser.dependency
            ],
            path: "Tests/TestSupport"
        )
    }
}

enum CoreModule {
    static let dependency: Target.Dependency = "CoreModule"
    static var product: Product {
        .library(name: "CoreModule", targets: ["CoreModule"])
    }
    static var target: Target {
        .target(
            name: "CoreModule",
            dependencies: [
                AST.dependency,
                Diagnostics.dependency,
                Lexer.dependency,
                Parser.dependency
            ],
            exclude: ["Resources"],
            swiftSettings: upcomingFeatures,
            plugins: ["EmbedResources"]
        )
    }
    
    /// Compiles `Resources` into the binary, so `coolc` runs without a
    /// resource bundle next to it.
    static var embedPlugin: Target {
        .plugin(
            name: "EmbedResources",
            capability: .buildTool(),
            dependencies: ["ResourceEmbedder"]
        )
    }
    static var embedder: Target {
        .executableTarget(
            name: "ResourceEmbedder",
            swiftSettings: upcomingFeatures
        )
    }
}

enum CodeGen {
    static let dependency: Target.Dependency = "CodeGen"
    static var product: Product {
        .library(name: "CodeGen", targets: ["CodeGen"])
    }
    static var target: Target {
        .target(
            name: "CodeGen",
            dependencies: [
                AST.dependency,
                Basic.dependency,
                Diagnostics.dependency,
                Sema.dependency
            ],
            swiftSettings: upcomingFeatures
        )
    }
    static var tests: Target {
        .testTarget(
            name: "CodeGenTests",
            dependencies: [
                CodeGen.dependency,
                Sema.dependency,
                Parser.dependency,
                Lexer.dependency,
                TestSupport.dependency,
                CoreModule.dependency
            ],
            resources: [.copy("Expected")],
            swiftSettings: upcomingFeatures
        )
    }
}
