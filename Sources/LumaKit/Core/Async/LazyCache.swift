//
//  LazyCache.swift
//
//
//  Created by Anton Kormakov on 25.07.2024.
//

import Foundation

public final actor LazyCache<Key: AnyObject & Hashable, Value> {
    public typealias Provider = (Key) async throws -> Value

    lazy var cache: NSCache<Key, Lazy<Value>> = .init()
    public init() {}

    public func fetch(for key: Key, provider: @escaping Provider) async throws -> Value {
        if let lazyValue = cache.object(forKey: key) {
            return try await lazyValue.fetch()
        }

        let value = Lazy<Value> {
            return try await provider(key)
        }
        cache.setObject(value, forKey: key)
        return try await value.fetch()
    }
}
