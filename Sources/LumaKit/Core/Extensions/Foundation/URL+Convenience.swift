//
//  URL+Convenience.swift
//  Reels
//
//  Created by Anton Kormakov on 05.06.2023.
//

import Foundation

public extension URL {
    static var root: URL = URL(fileURLWithPath: "/")

    static func temporary(withExtension ext: String) -> URL {
        let fileName = UUID().uuidString
        return URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(fileName)
                .appendingPathExtension(ext)
    }

    static func appStoreURL(withIdentifier id: String, openReviewPage: Bool = false) -> URL? {
        var components = URLComponents()
        components.scheme = "itms-apps"
        components.host = "itunes.apple.com"
        components.path = "/app/id" + id
        if openReviewPage {
            components.queryItems = [URLQueryItem(name: "action", value: "write-review")]
        }
        return components.url
    }
}
