//
//  Equatable+Convenience.swift
//  LumaKit
//
//  Created by Anton Kormakov on 04.11.2024.
//

public final class EquatableKeyPath<T> {
    let handler: (T, T) -> Bool

    public init<V: Equatable>(keyPath: KeyPath<T, V>) {
        handler = { (lhs: T, rhs: T) in
            return lhs[keyPath: keyPath] == rhs[keyPath: keyPath]
        }
    }

    public func compare(_ lhs: T, rhs: T) -> Bool {
        return handler(lhs, rhs)
    }
}

public extension Equatable {

    func isEqual(to object: Self, keyPaths: EquatableKeyPath<Self>...) -> Bool {
        return keyPaths.allSatisfy { (keyPath: EquatableKeyPath<Self>) in
            return keyPath.compare(self, rhs: object)
        }
    }

    func isEqual(to object: Self, keyPaths: [EquatableKeyPath<Self>]) -> Bool {
        return keyPaths.allSatisfy { (keyPath: EquatableKeyPath<Self>) in
            return keyPath.compare(self, rhs: object)
        }
    }
}
