# TestVisible

TestVisible is a Swift package that provides a custom macro for exposing private properties and methods of classes and structs for testing purposes. It leverages SwiftSyntax to generate extensions dynamically, making testing private APIs more convenient.

## Features

- 🛠️ Easily expose private properties and methods for testing.
- 📦 Compatible with both classes and structs.
- 🎛️ Customizable property name for the test access interface.

## Requirements

- Swift 5.9 or later
- Compatible with SwiftSyntax 5.0.9 or later

## Installation

### Swift Package Manager (SPM)

Add TestVisible as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/watanabetoshinori/TestVisible.git", from: "1.0.0")
]
```

## Usage

Apply the @TestVisible macro to your class or struct:

```swift
import TestVisible

@TestVisible
struct MyStruct {
    private var privateVariable: String = "Hello"
    
    private func privateMethod() -> String {
        return "World"
    }
}

// Usage in tests
let myStruct = MyStruct()
#expect(myStruct.test.privateVariable == "Hello")
#expect(myStruct.test.privateMethod() == "World")
```

### Example of Generated Code

When you annotate your class or struct with `@TestVisible`, the following extension is dynamically generated:

```swift
extension MyStruct {
    var test: TestInterface {
        TestInterface(self)
    }

    struct TestInterface {
        private let _instance: MyStruct
        init(_ instance: MyStruct) { self._instance = instance }

        var privateVariable: String {
            return _instance.privateVariable
        }

        func privateMethod() -> String {
            return _instance.privateMethod()
        }
    }
}
```

### Custom Property Name

By default, the testable property is named `test`. You can specify a custom name:

```swift
@TestVisible(property: "customTest")
class MyClass {
    private var data: Int = 42
}

// Access using the custom name
let customTestable = MyClass().customTest.data
```

## Running Tests

To ensure the functionality of the `TestVisible` macro, you can run the included test suite using `XCTest`. Follow these steps to execute the tests:

1. Open a terminal.
2. Navigate to the root directory of your project.
3. Run the following command:

   ```bash
   swift test
   ```

## FAQ

### Why use TestVisible instead of making properties public?
TestVisible helps maintain encapsulation by exposing private APIs only for testing, ensuring your production code remains clean and secure.

### Does it work with enums?
Currently, TestVisible is designed for classes and structs. Enum support is not available yet.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

Watanabe Toshinori

## Acknowledgments

This project was inspired in part by the [TestableMacro](https://github.com/fernandolucheti/TestableMacro) repository by Fernando Lucheti. 
We appreciate the insights and ideas it provided during the development of TestVisible.
