//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import Foundation

public protocol OptionalType {
    associatedtype T
    var optional: T? { get }
}

extension Optional: OptionalType {
    public enum OptionalError: LocalizedError {
        case noValue(type: Wrapped.Type, hint: String?)

        public var errorDescription: String? {
            switch self {
            case let .noValue(type: _, hint: hint):
                return hint
            }
        }
    }

    public typealias T = Wrapped

    public var optional: T? {
        return self
    }

    public func unwrap(hint: String? = nil) throws -> T {
        guard let value = optional else {
            throw OptionalError.noValue(type: T.self, hint: hint)
        }

        return value
    }
}
