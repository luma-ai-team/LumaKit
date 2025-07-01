//
//  WebSearchKey.swift
//  LumaKit
//
//  Created by Anton K on 27.06.2025.
//

public final class WebSearchKey: Hashable, Codable {
    public let term: String
    public let index: Int

    public init(term: String, index: Int = 0) {
        self.term = term
        self.index = index
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(term)
        hasher.combine(index)
    }
}

extension WebSearchKey: Equatable {
    public static func == (lhs: WebSearchKey, rhs: WebSearchKey) -> Bool {
        return (lhs.term == rhs.term) &&
               (lhs.index == rhs.index)
    }
}
