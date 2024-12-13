//
//  TestVisibleMacro.swift
//  TestVisible
//
//  Created by Watanabe Toshinori on 2024/12/13.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

#if !canImport(SwiftSyntax600)
import SwiftSyntaxMacroExpansion
#endif

public struct TestVisibleMacro: ExtensionMacro {

    static let defaultProperty = "test"

    static let defaultBaseProperty = "_instance"

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {

        if !declaration.isStruct, !declaration.isClass {
            throw DiagnosticsError(
                syntax: node,
                message: "'@TestVisible' can only be applied to classes or structs.",
                id: .invalidApplication)
        }

        let property: String = {
            if case let .argumentList(arguments) = node.arguments,
                let value = arguments.first(where: { $0.label?.text == "property" })?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                return value
            }
            return Self.defaultProperty
        }()

        let variables = TestVisibleMacro.accessibleVariables(type, declaration)
        let functions = TestVisibleMacro.accessibleFunctions(type, declaration)

        let decl: DeclSyntax =
            """
            extension \(raw: type.trimmedDescription) {
                var \(raw: property): TestVisible {
                    TestVisible(self)
                }
            
                struct TestVisible {
                    private var \(raw: Self.defaultBaseProperty): \(raw: type.trimmedDescription)
            
                    init(_ instance: \(raw: type.trimmedDescription)) {
                        self.\(raw: Self.defaultBaseProperty) = instance
                    }
            
                    \(raw: variables.joined(separator: "\n        "))

                    \(raw: functions.joined(separator: "\n        "))
                }
            }
            """
        return [
            decl.cast(ExtensionDeclSyntax.self),
        ]
    }

    /// Generates property declarations to access private variables in a type.
    ///
    /// - Parameters:
    ///   - type: The type the macro is attached to.
    ///   - group: The declaration group (e.g., class or struct) containing private variables.
    /// - Returns: An array of property declarations as strings, exposing private variables.
    static func accessibleVariables(_ type: some SwiftSyntax.TypeSyntaxProtocol, _ group: DeclGroupSyntax) -> [String] {
        group.privateVariables
            .compactMap { variable in
                let variableName = variable.bindings.first?.pattern.description.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let variableType = variable.bindings.first?.typeAnnotation?.type.description.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !variableName.isEmpty else {
                    return nil
                }

                let staticKeyword = variable.modifiers.contains(where: { $0.name.text == "static" }) ? "static " : ""
                let caller = !staticKeyword.isEmpty ? type.trimmedDescription : defaultBaseProperty

                var decl = [String]()
                decl.append("\(staticKeyword)var \(variableName): \(variableType ?? "Any") {")
                if variable.isReadWrite {
                    // Read-Write property
                    decl.append("    get {")
                    decl.append("        \(caller).\(variableName)")
                    decl.append("    }")
                    decl.append("    set {")
                    if variableType != nil {
                        decl.append("        \(caller).\(variableName) = newValue")
                    } else {
                        decl.append(#"        fatalError("To use a setter, you need to explicitly define the type.")"#)
                    }
                    decl.append("    }")
                } else {
                    // Read-Only or Computed property
                    decl.append("    \(caller).\(variableName)")
                }
                decl.append("}")
                return decl
            }
            .reduce([], +)
    }

    /// Generates function declarations to access private methods in a type.
    ///
    /// - Parameters:
    ///   - type: The type the macro is attached to.
    ///   - group: The declaration group (e.g., class or struct) containing private functions.
    /// - Returns: An array of function declarations as strings, exposing private methods.
    static func accessibleFunctions(_ type: some SwiftSyntax.TypeSyntaxProtocol, _ group: DeclGroupSyntax) -> [String] {
        group.privateFunctions
            .compactMap { function in
                let functionName = function.name.text

                let parameters = function.signature.parameterClause.description.trimmingCharacters(in: .whitespaces)
                let arguments = function.signature.parameterClause.parameters
                    .map { param in
                        let firstName = param.firstName.text
                        let secondName = param.secondName?.text
                        let inoutKeyword = param.type.description.contains("inout") ? "&" : ""

                        if let secondName {
                            if firstName == "_" {
                                return "\(inoutKeyword)\(secondName)"
                            } else {
                                return "\(firstName): \(inoutKeyword)\(secondName)"
                            }
                        } else {
                            return "\(firstName): \(inoutKeyword)\(firstName)"
                        }
                    }
                    .joined(separator: ", ")

                let staticKeyword = function.modifiers.contains(where: { $0.name.text == "static" }) ? "static " : ""
                let mutatingKeyword = function.modifiers.contains(where: { $0.name.text == "mutating" }) ? "mutating " : ""
                let target = !staticKeyword.isEmpty ? type.trimmedDescription : defaultBaseProperty

                let genericParameters: String = {
                    if let parameters = function.genericParameterClause?.parameters {
                        return "<\(parameters.map { $0.name.text }.joined(separator: ", "))>"
                    }
                    return ""
                }()
                let whenParameters = function.genericWhereClause?.description.trimmingCharacters(in: .whitespaces) ?? ""

                let asyncKeyword = function.signature.effectSpecifiers?.asyncSpecifier?.text.trimmingCharacters(in: .whitespaces)
                let throwsKeyword = function.signature.effectSpecifiers?.throwsClause?.description.trimmingCharacters(in: .whitespaces)
                let returnType = function.signature.returnClause?.description.trimmingCharacters(in: .whitespaces)
                let suffix = [asyncKeyword, throwsKeyword, returnType, whenParameters].compactMap { $0 }.joined(separator: " ")

                let awaitKeyword = asyncKeyword != nil ? "await " : nil
                let tryKeyword = throwsKeyword != nil ? "try " : nil
                let prefix = [tryKeyword, awaitKeyword].compactMap { $0 }.joined()

                var decl = [String]()
                decl.append("\(staticKeyword)\(mutatingKeyword)func \(functionName)\(genericParameters)\(parameters)\(suffix){")
                decl.append("    \(prefix)\(target).\(functionName)(\(arguments))")
                decl.append("}")
                return decl
            }
            .reduce([], +)
    }
}

struct TestableAccessMacroDiagnostic: DiagnosticMessage {
    enum ID: String {
        case invalidApplication = "invalid application"
    }

    var message: String

    var diagnosticID: MessageID

    var severity: DiagnosticSeverity

    init(
        message: String, diagnosticID: SwiftDiagnostics.MessageID,
        severity: SwiftDiagnostics.DiagnosticSeverity = .error
    ) {
        self.message = message
        self.diagnosticID = diagnosticID
        self.severity = severity
    }

    init(
        message: String,
        domain: String,
        id: ID,
        severity: SwiftDiagnostics.DiagnosticSeverity = .error
    ) {
        self.message = message
        self.diagnosticID = MessageID(domain: domain, id: id.rawValue)
        self.severity = severity
    }
}

extension DiagnosticsError {
    init<S: SyntaxProtocol>(
        syntax: S,
        message: String,
        domain: String = "TestVisible",
        id: TestableAccessMacroDiagnostic.ID,
        severity: SwiftDiagnostics.DiagnosticSeverity = .error
    ) {
        self.init(diagnostics: [
            Diagnostic(
                node: Syntax(syntax),
                message: TestableAccessMacroDiagnostic(message: message, domain: domain, id: id, severity: severity)
            )
        ])
    }
}
