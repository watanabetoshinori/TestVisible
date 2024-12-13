//
//  Plugin.swift
//  TestVisible
//
//  Created by Watanabe Toshinori on 2024/12/13.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        TestVisibleMacro.self,
    ]
}
