// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "TestVisible",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "TestVisible",
            targets: ["TestVisible"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0"..<"601.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.5.2"),
    ],
    targets: [
        .target(
            name: "TestVisible",
            dependencies: [
                "TestVisiblePlugin"
            ]
        ),
        .macro(
            name: "TestVisiblePlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "TestVisiblePluginTests",
            dependencies: [
                "TestVisiblePlugin",
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
    ]
)
