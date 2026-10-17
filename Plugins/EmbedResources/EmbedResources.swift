//
//  EmbedResources.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 17/10/2026.
//

import Foundation
import PackagePlugin

/// Embeds every file in a target's `Resources` folder as a string constant
/// in `EmbeddedResources`, so executables don't need a resource bundle.
@main
struct EmbedResources: BuildToolPlugin {
    func createBuildCommands(
        context: PluginContext,
        target: any Target
    ) throws -> [Command] {
        let resources = target.directoryURL.appending(path: "Resources")
        let inputs = try FileManager.default
            .contentsOfDirectory(at: resources, includingPropertiesForKeys: nil)
            .filter { !$0.lastPathComponent.hasPrefix(".") }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        let output = context.pluginWorkDirectoryURL.appending(path: "EmbeddedResources.swift")
        
        return [
            .buildCommand(
                displayName: "Embedding resources for \(target.name)",
                executable: try context.tool(named: "ResourceEmbedder").url,
                arguments: [output.path] + inputs.map(\.path),
                inputFiles: inputs,
                outputFiles: [output]
            )
        ]
    }
}
