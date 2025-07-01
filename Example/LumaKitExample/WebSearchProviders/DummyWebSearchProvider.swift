//
//  DummyWebSearchProvider.swift
//  LumaKitExample
//
//  Created by Anton K on 27.06.2025.
//

import UIKit
import LumaKit

final class DummyWebSearchProvider: WebSearchProvider {
    enum DummyError: Error {
        case hello
    }

    final class Result: SearchResult {
        let identifier: String
        let url: URL
        let size: CGSize

        init(identifier: String, url: URL, size: CGSize) {
            self.identifier = identifier
            self.url = url
            self.size = size
        }
    }

    func search(_ key: WebSearchKey) async throws -> [any SearchResult] {
        if key.term == "error" {
            throw DummyError.hello
        }

        return [
            Result(identifier: "1",
                   url: .init(string: "https://picsum.photos/id/237/200/300")!,
                   size: .init(width: 200, height: 300)),
            Result(identifier: "2",
                   url: .init(string: "https://picsum.photos/id/238/200/300")!,
                   size: .init(width: 200, height: 300)),
            Result(identifier: "3",
                   url: .init(string: "https://picsum.photos/id/239/200/300")!,
                   size: .init(width: 200, height: 300)),
            Result(identifier: "4",
                   url: .init(string: "https://picsum.photos/id/240/200/300")!,
                   size: .init(width: 200, height: 300)),
            Result(identifier: "5",
                   url: .init(string: "https://picsum.photos/id/241/200/300")!,
                   size: .init(width: 200, height: 300)),
            Result(identifier: "6",
                   url: .init(string: "https://picsum.photos/id/242/200/300")!,
                   size: .init(width: 200, height: 300)),
            Result(identifier: "7",
                   url: .init(string: "https://picsum.photos/id/243/200/300")!,
                   size: .init(width: 200, height: 300)),
            Result(identifier: "8",
                   url: .init(string: "https://picsum.photos/id/244/200/300")!,
                   size: .init(width: 200, height: 300))
        ]
    }
    
    func cancel() {
        //
    }
}
