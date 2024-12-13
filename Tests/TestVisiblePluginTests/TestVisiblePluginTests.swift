//
//  TestVisiblePluginTests.swift
//  TestVisible
//
//  Created by Watanabe Toshinori on 2024/12/13.
//

#if canImport(TestVisiblePlugin)
import MacroTesting
import TestVisiblePlugin
import XCTest

final class TestVisiblePluginTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
            macros: [
                TestVisibleMacro.self,
            ]
        ) {
            super.invokeTest()
        }
    }

    func testMacroWithStruct() throws {
        assertMacro {
           """
           @TestVisible
           struct User {
               var name: String
           
               var nickname: String 
               
               private var age: Int
           
               init(name: String, nickname: String, age: Int) {
                   self.name = name
                   self.nickname = nickname
                   self.age = age
               }
           
               func introduce() -> String {
                   "Hello, my name is" +  name + ". I'm " + String(age) + "  years old."
               }
           
               private mutating func haveBirthday() {
                   age += 1
               }
           }
           """
        } expansion: {
            """
            struct User {
                var name: String
            
                var nickname: String 
                
                private var age: Int
            
                init(name: String, nickname: String, age: Int) {
                    self.name = name
                    self.nickname = nickname
                    self.age = age
                }
            
                func introduce() -> String {
                    "Hello, my name is" +  name + ". I'm " + String(age) + "  years old."
                }
            
                private mutating func haveBirthday() {
                    age += 1
                }
            }
            
            extension User {
                var test: TestVisible {
                    TestVisible(self)
                }
            
                struct TestVisible {
                    private var _instance: User
            
                    init(_ instance: User) {
                        self._instance = instance
                    }
            
                    var age: Int {
                        get {
                            _instance.age
                        }
                        set {
                            _instance.age = newValue
                        }
                    }
            
                    mutating func haveBirthday() {
                        _instance.haveBirthday()
                    }
                }
            }
            """
        }
    }

    func testMacroWithClass() throws {
        assertMacro {
            """
            @TestVisible
            class User {
                var name: String
            
                var nickname: String
            
                private var age: Int
            
                init(name: String, nickname: String, age: Int) {
                    self.name = name
                    self.nickname = nickname
                    self.age = age
                }
            
                func introduce() -> String {
                    "Hello, my name is" +  name + ". I'm " + String(age) + "  years old."
                }
            
                private func haveBirthday() {
                    age += 1
                }
            }
            """
        } expansion: {
            """
            class User {
                var name: String
            
                var nickname: String
            
                private var age: Int
            
                init(name: String, nickname: String, age: Int) {
                    self.name = name
                    self.nickname = nickname
                    self.age = age
                }
            
                func introduce() -> String {
                    "Hello, my name is" +  name + ". I'm " + String(age) + "  years old."
                }
            
                private func haveBirthday() {
                    age += 1
                }
            }
            
            extension User {
                var test: TestVisible {
                    TestVisible(self)
                }
            
                struct TestVisible {
                    private var _instance: User
            
                    init(_ instance: User) {
                        self._instance = instance
                    }
            
                    var age: Int {
                        get {
                            _instance.age
                        }
                        set {
                            _instance.age = newValue
                        }
                    }
            
                    func haveBirthday() {
                        _instance.haveBirthday()
                    }
                }
            }
            """
        }
    }

    func testMacroErrorOnEnum() throws {
        assertMacro {
           """
           @TestVisible
           enum MyEnum {
               case a, b, c
           }
           """
        } diagnostics: {
            """
            @TestVisible
            ┬───────────
            ╰─ 🛑 '@TestVisible' can only be applied to classes or structs.
            enum MyEnum {
                case a, b, c
            }
            """
        }
    }

    func testMacroWithProperties() throws {
        assertMacro {
            """
            @TestVisible
            class User {
                private var storedValue: Int = 42
            
                private let storedConstant: String = "constant"
            
                private var computedValue: Int {
                    return storedValue * 2
                }
            
                private var computedValueWithSetter: Int {
                    get { 
                        storedValue * 2
                    }
                    set {
                        storedValue = newValue / 2 
                    }
                }
            
                private var computedValueWithoutSetter: Int {
                    get { 
                        storedValue * 2
                    }
                }
            
                private lazy var lazyValue: String = "Lazy Loaded"
            
                private static var staticValue: Int = 100
            }
            """
        } expansion: {
            """
            class User {
                private var storedValue: Int = 42
            
                private let storedConstant: String = "constant"
            
                private var computedValue: Int {
                    return storedValue * 2
                }
            
                private var computedValueWithSetter: Int {
                    get { 
                        storedValue * 2
                    }
                    set {
                        storedValue = newValue / 2 
                    }
                }
            
                private var computedValueWithoutSetter: Int {
                    get { 
                        storedValue * 2
                    }
                }
            
                private lazy var lazyValue: String = "Lazy Loaded"
            
                private static var staticValue: Int = 100
            }
            
            extension User {
                var test: TestVisible {
                    TestVisible(self)
                }
            
                struct TestVisible {
                    private var _instance: User
            
                    init(_ instance: User) {
                        self._instance = instance
                    }
            
                    var storedValue: Int {
                        get {
                            _instance.storedValue
                        }
                        set {
                            _instance.storedValue = newValue
                        }
                    }
                    var storedConstant: String {
                        _instance.storedConstant
                    }
                    var computedValue: Int {
                        _instance.computedValue
                    }
                    var computedValueWithSetter: Int {
                        get {
                            _instance.computedValueWithSetter
                        }
                        set {
                            _instance.computedValueWithSetter = newValue
                        }
                    }
                    var computedValueWithoutSetter: Int {
                        _instance.computedValueWithoutSetter
                    }
                    var lazyValue: String {
                        get {
                            _instance.lazyValue
                        }
                        set {
                            _instance.lazyValue = newValue
                        }
                    }
                    static var staticValue: Int {
                        get {
                            User.staticValue
                        }
                        set {
                            User.staticValue = newValue
                        }
                    }
            
            
                }
            }
            """
        }
    }

    func testMacroWithFunctions() throws {
        assertMacro {
            """
            @TestVisible
            class User {
                private func noParamterNoReturn() {
                    print("test")
                }
            
                private func withReturn() -> Int {
                    return 1
                }
            
                private func withParameters(param1: Int, param2: String) -> Int {
                    return 1
                }
            
                private func withDefaultParameters(param1: Int = 0, param2: String? = nil) -> Int {
                    return 1
                }
            
                private func withUnderbarParameters(_ param1: Int, _ param2: String) -> Int {
                    return 1
                }
            
                private func withKeywodParameters(with param1: Int, param2: String) -> Int {
                    return 1
                }
            
                private func withInoutParameter(value: inout Int) {
                    value *= 2
                }
            
                private func withCompletionHandler(param1: Int, param2: @escaping (Bool) -> Void) -> Int {
                    return 1
                }
            
                private func genericMethod<T>(value: T) -> T {
                    return value
                }

                private func genericWhereMethod<T>(value: T) -> T where T: Equtable {
                    return value
                }
            
                private func asyncMethod(param1: Int, param2: String) async -> Int {
                    return 1
                }
            
                private func asyncThrowsMethod(param1: Int, param2: String) async throws -> Int {
                    return 1
                }
            
                private static func staicMethod() {
                    print("test")
                }
            }
            """
        } expansion: {
            """
            class User {
                private func noParamterNoReturn() {
                    print("test")
                }
            
                private func withReturn() -> Int {
                    return 1
                }
            
                private func withParameters(param1: Int, param2: String) -> Int {
                    return 1
                }
            
                private func withDefaultParameters(param1: Int = 0, param2: String? = nil) -> Int {
                    return 1
                }
            
                private func withUnderbarParameters(_ param1: Int, _ param2: String) -> Int {
                    return 1
                }
            
                private func withKeywodParameters(with param1: Int, param2: String) -> Int {
                    return 1
                }
            
                private func withInoutParameter(value: inout Int) {
                    value *= 2
                }
            
                private func withCompletionHandler(param1: Int, param2: @escaping (Bool) -> Void) -> Int {
                    return 1
                }
            
                private func genericMethod<T>(value: T) -> T {
                    return value
                }

                private func genericWhereMethod<T>(value: T) -> T where T: Equtable {
                    return value
                }
            
                private func asyncMethod(param1: Int, param2: String) async -> Int {
                    return 1
                }
            
                private func asyncThrowsMethod(param1: Int, param2: String) async throws -> Int {
                    return 1
                }
            
                private static func staicMethod() {
                    print("test")
                }
            }
            
            extension User {
                var test: TestVisible {
                    TestVisible(self)
                }
            
                struct TestVisible {
                    private var _instance: User
            
                    init(_ instance: User) {
                        self._instance = instance
                    }
            
            
            
                    func noParamterNoReturn() {
                        _instance.noParamterNoReturn()
                    }
                    func withReturn() -> Int {
                        _instance.withReturn()
                    }
                    func withParameters(param1: Int, param2: String) -> Int {
                        _instance.withParameters(param1: param1, param2: param2)
                    }
                    func withDefaultParameters(param1: Int = 0, param2: String? = nil) -> Int {
                        _instance.withDefaultParameters(param1: param1, param2: param2)
                    }
                    func withUnderbarParameters(_ param1: Int, _ param2: String) -> Int {
                        _instance.withUnderbarParameters(param1, param2)
                    }
                    func withKeywodParameters(with param1: Int, param2: String) -> Int {
                        _instance.withKeywodParameters(with: param1, param2: param2)
                    }
                    func withInoutParameter(value: inout Int) {
                        _instance.withInoutParameter(value: &value)
                    }
                    func withCompletionHandler(param1: Int, param2: @escaping (Bool) -> Void) -> Int {
                        _instance.withCompletionHandler(param1: param1, param2: param2)
                    }
                    func genericMethod<T>(value: T) -> T {
                        _instance.genericMethod(value: value)
                    }
                    func genericWhereMethod<T>(value: T) -> T where T: Equtable {
                        _instance.genericWhereMethod(value: value)
                    }
                    func asyncMethod(param1: Int, param2: String) async -> Int {
                        await _instance.asyncMethod(param1: param1, param2: param2)
                    }
                    func asyncThrowsMethod(param1: Int, param2: String) async throws -> Int {
                        try await _instance.asyncThrowsMethod(param1: param1, param2: param2)
                    }
                    static func staicMethod() {
                        User.staicMethod()
                    }
                }
            }
            """
        }
    }

    func testMacroWithCustomPropety() throws {
        assertMacro {
            """
            @TestVisible(property: "qux")
            class User {
                private var age: Int
            }
            """
        } expansion: {
            """
            class User {
                private var age: Int
            }
            
            extension User {
                var qux: TestVisible {
                    TestVisible(self)
                }
            
                struct TestVisible {
                    private var _instance: User
            
                    init(_ instance: User) {
                        self._instance = instance
                    }
            
                    var age: Int {
                        get {
                            _instance.age
                        }
                        set {
                            _instance.age = newValue
                        }
                    }


                }
            }
            """
        }
    }
}
#endif
