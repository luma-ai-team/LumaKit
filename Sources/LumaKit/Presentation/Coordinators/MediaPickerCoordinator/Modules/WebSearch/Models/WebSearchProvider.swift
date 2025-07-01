//
//  WebSearchProvider.swift
//  LumaKit
//
//  Created by Anton K on 27.06.2025.
//

public protocol WebSearchProvider {
    func search(_ key: WebSearchKey) async throws -> [WebSearchResult]
    func cancel()
}
