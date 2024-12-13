//
//  Macros.swift
//  TestVisible
//
//  Created by Watanabe Toshinori on 2024/12/13.
//

/// A macro that exposes private properties or methods for testing purposes.
///
/// The `@TestVisible` macro generates extensions to allow controlled access to private
/// members of a class or struct. This is useful in scenarios where unit testing requires
/// interaction with internal implementation details without making them publicly accessible.
///
/// ### Usage
/// Apply the `@TestVisible` macro to a class or struct to expose private members as test-accessible properties or methods:
///
/// ```swift
/// @TestVisible()
/// class User {
///     private var value: Int
/// }
/// ```
///
/// After macro expansion, the private members will be accessible via generated extensions:
///
/// ```swift
/// let value = User().test.value
/// ```
///
/// ### Parameters
/// - `property`: A string specifying the prefix or name of the property for test access. Defaults to `"test"`.
///
/// ### Requirements
/// - The macro should be applied only to classes or structs.
/// - Attempting to apply this macro to unsupported declarations will result in a compilation error.
@attached(extension, names: arbitrary)
public macro TestVisible(property: String = "test") =
    #externalMacro(module: "TestVisiblePlugin", type: "TestVisibleMacro")
