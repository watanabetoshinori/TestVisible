//
//  User.swift
//  Example
//
//  Created by Watanabe Toshinori on 2024/12/13.
//

import TestVisible

@TestVisible
class User {
    private var storedValue: Int = 42

    private func withParameters(_ param1: Int, _ param2: Int) -> Int {
        param1 + param2
    }

    private func genericMethod<T>(value: T) -> T where T: Equatable {
        return value
    }
}
