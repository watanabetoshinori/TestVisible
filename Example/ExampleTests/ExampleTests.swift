//
//  ExampleTests.swift
//  ExampleTests
//
//  Created by Watanabe Toshinori on 2024/12/13.
//

import Testing
@testable import Example

struct ExampleTests {

    @Test func userTests() async throws {
        let user = User()
        #expect(user.test.storedValue == 42)
        #expect(user.test.withParameters(1, 2) == 3)
    }

}
