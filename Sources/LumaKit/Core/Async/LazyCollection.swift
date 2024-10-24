//
//  LazyCollection.swift
//
//
//  Created by Anton Kormakov on 25.07.2024.
//

import Foundation

public final actor LazyCollection<Key: Hashable, Value> {
    public typealias Provider = @Sendable (Key) async throws -> Value

    lazy var map: [Key: Lazy<Value>] = [:]
    public init() {}

    public func fetch(for key: Key, provider: @escaping Provider) async throws -> Value {
        if let lazyValue = map[key] {
            return try await lazyValue.fetch()
        }

        let value = Lazy<Value> {
            return try await provider(key)
        }
        map[key] = value
        return try await value.fetch()
    }

    public func remove(key: Key) {
        map.removeValue(forKey: key)
    }
}
