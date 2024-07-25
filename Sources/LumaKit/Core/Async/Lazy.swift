//
//  Lazy.swift
//
//
//  Created by Anton Kormakov on 25.07.2024.
//

import Foundation

public final actor Lazy<T> {
    public typealias Provider = @Sendable () async throws -> T

    let task: Task<T, Error>
    public init(provider: @escaping Provider) {
        task = Task {
            return try await provider()
        }
    }

    public func fetch() async throws -> T {
        return try await task.value
    }
}
