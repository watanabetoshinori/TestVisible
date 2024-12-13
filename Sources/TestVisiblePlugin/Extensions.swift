//
//  Extensions.swift
//  TestVisible
//
//  Created by Watanabe Toshinori on 2024/12/13.
//

import SwiftSyntax

extension DeclGroupSyntax {
    var isStruct: Bool {
        self.is(StructDeclSyntax.self)
    }

    var isClass: Bool {
        self.is(ClassDeclSyntax.self)
    }

    var privateVariables: [VariableDeclSyntax] {
        memberBlock.members
            .compactMap {
                $0.decl.as(VariableDeclSyntax.self)
            }
            .filter {
                $0.isPrivate
            }
    }

    var privateFunctions: [FunctionDeclSyntax] {
        memberBlock.members
            .compactMap {
                $0.decl.as(FunctionDeclSyntax.self)
            }
            .filter {
                $0.isPrivate
            }
    }
}

extension VariableDeclSyntax {
    var isPrivate: Bool {
        modifiers.contains(where: { $0.name.text == "private" })
    }

    var name: String? {
        bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
    }

    var isReadWrite: Bool {
        guard let accessors = bindings.first?.accessorBlock?.accessors else {
            return bindingSpecifier.text == "var"
        }
        switch accessors {
        case .accessors(let accessor):
            return accessor.contains { $0.accessorSpecifier.text == "set" }
        case .getter:
            return false
        }
    }
}

extension FunctionDeclSyntax {
    var isPrivate: Bool {
        modifiers.contains(where: { $0.name.text == "private" })
    }
}
