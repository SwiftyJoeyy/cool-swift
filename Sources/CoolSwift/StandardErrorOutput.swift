//
//  StandardErrorOutput.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 17/10/2026.
//

import Diagnostics
import Foundation

struct StandardErrorOutput: DiagnosticsOutput {
    var supportsColor: Bool {
        return isatty(STDERR_FILENO) != 0
            && ProcessInfo.processInfo.environment["NO_COLOR"] == nil
    }
    
    func write(_ text: String) {
        FileHandle.standardError.write(Data(text.utf8))
    }
}
