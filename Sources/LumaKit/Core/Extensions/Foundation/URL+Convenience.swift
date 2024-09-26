//
//  URL+Convenience.swift
//  Reels
//
//  Created by Anton Kormakov on 05.06.2023.
//

import Foundation

extension URL {
    public static var root: URL = URL(fileURLWithPath: "/")
    public static var dummy: URL = URL(fileURLWithPath: "/luma-kit-dummy")
    static var bundleURLScheme: String = "bundle"
    static var homeURLScheme: String = "home"

    public var isDummy: Bool {
        return self == URL.dummy
    }

    public var isBundleRelative: Bool {
        return bundleRelativeURL?.scheme == Self.bundleURLScheme
    }

    public var bundleRelativeURL: URL? {
        if scheme == Self.bundleURLScheme {
            return self
        }

        let bundleURL = (Bundle.main.resourceURL ?? Bundle.main.bundleURL).resolvingSymlinksInPath()
        guard path.starts(with: bundleURL.path) else {
            return nil
        }

        let relativePath = path
            .replacingOccurrences(of: bundleURL.path, with: "")
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        return URL(string: "\(Self.bundleURLScheme)://\(relativePath ?? "")")
    }

    public var isHomeRelative: Bool {
        return homeRelativeURL?.scheme == Self.homeURLScheme
    }

    public var homeRelativeURL: URL? {
        if scheme == Self.homeURLScheme {
            return self
        }

        let homeURL = URL(fileURLWithPath: NSHomeDirectory()).resolvingSymlinksInPath()
        guard path.starts(with: homeURL.path) else {
            return nil
        }

        let relativePath = path
            .replacingOccurrences(of: homeURL.path, with: "")
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        return URL(string: "\(Self.homeURLScheme)://\(relativePath ?? "")")
    }

    public var relativeURL: URL {
        return resolvingSymlinksInPath().bundleRelativeURL ?? resolvingSymlinksInPath().homeRelativeURL ?? self
    }

    public static func resolving(relativeURL: URL) -> URL {
        if relativeURL.scheme == bundleURLScheme {
            let bundleURL = Bundle.main.resourceURL ?? Bundle.main.bundleURL
            return bundleURL.appendingPathComponent(relativeURL.path)
        }

        if relativeURL.scheme == homeURLScheme {
            let homeURL = URL(fileURLWithPath: NSHomeDirectory())
            return homeURL.appendingPathComponent(relativeURL.path)
        }

        return relativeURL
    }

    public static func temporary(withExtension ext: String) -> URL {
        let fileName = UUID().uuidString
        return URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(fileName)
                .appendingPathExtension(ext)
    }

    public static func appStoreURL(withIdentifier id: String, openReviewPage: Bool = false) -> URL? {
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
