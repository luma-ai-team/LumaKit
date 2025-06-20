//
//  AssetProvider.swift
//  LumaKit
//
//  Created by Anton Kormakov on 06.01.2025.
//

import UIKit
import AVFoundation

public final class AssetProvider {
    public final class Asset<T>: Equatable {
        public let source: URL
        public private(set) var cached: T?
        private let provider: () async throws -> T

        public static func == (lhs: Asset<T>, rhs: Asset<T>) -> Bool {
            return lhs.source == rhs.source
        }

        init(source: URL, cached: T?, provider: @escaping () async throws -> T) {
            self.source = source
            self.cached = cached
            self.provider = provider

            Task {
                try await resolve()
            }
        }

        public func resolve() async throws -> T {
            if let cached = cached {
                return cached
            }

            let value = try await provider()
            cached = value
            return value
        }
    }

    public let scope: String
    public let isTemporary: Bool

    private lazy var baseLocalURL: URL = {
        let basePath = isTemporary ? NSTemporaryDirectory() : NSHomeDirectory()
        return .init(fileURLWithPath: basePath)
               .appendingPathComponent("Documents")
               .appendingPathComponent("Assets")
               .appendingPathComponent(scope)
    }()

    private let session: URLSession = .shared
    private let fileManager: FileManager = .default
    private lazy var fetchers: LazyCollection<URL, URL> = .init()
    private lazy var imageCache: NSCache<NSString, UIImage> = .init()

    public init(scope: String = "default", isTemporary: Bool = false) {
        self.scope = scope
        self.isTemporary = isTemporary
        try? fileManager.createDirectory(at: baseLocalURL, withIntermediateDirectories: true)
    }

    private func makeLocalAssetURL(withIdentifier identifier: String, pathExtension: String? = nil) -> URL {
        var url = baseLocalURL.appendingPathComponent(identifier)
        if let pathExtension = pathExtension,
           pathExtension.isEmpty == false {
            url = url.appendingPathExtension(pathExtension)
        }
        return url
    }

    private func download(_ url: URL, identifier: String, pathExtension: String? = nil) async throws -> URL {
        objc_sync_enter(self)
        let fetchers = self.fetchers
        objc_sync_exit(self)

        return try await fetchers.fetch(for: url, provider: { _ in
            if url.isFileURL {
                return url
            }

            let targetURL = self.makeLocalAssetURL(withIdentifier: identifier, pathExtension: pathExtension)
            if self.fileManager.fileExists(atPath: targetURL.path) {
                return targetURL
            }

            let (output, _) = try await self.session.download(from: url)
            try? self.fileManager.removeItem(at: targetURL)
            try self.fileManager.copyItem(at: output, to: targetURL)

            #if DEBUG
            print("[II] Downloaded \(targetURL)")
            #endif

            return targetURL
        })
    }

    private func cachedImage(withIdentifier identifier: String) -> UIImage? {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        if let image = imageCache.object(forKey: identifier as NSString) {
            return image
        }

        let localURL = makeLocalAssetURL(withIdentifier: identifier as String)
        if let image = UIImage(contentsOfFile: localURL.path) {
            imageCache.setObject(image, forKey: identifier as NSString)
            return image
        }

        return nil
    }

    public func cacheImage(_ image: UIImage, at url: URL, identifier: String? = nil) async {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        let cacheKey = identifier ?? url.lastPathComponent
        if let data = image.pngData() {
            let localURL = self.makeLocalAssetURL(withIdentifier: cacheKey, pathExtension: "png")
            try? data.write(to: localURL)
        }

        imageCache.setObject(image, forKey: cacheKey as NSString)
    }

    public func fetchImageAsset(at url: URL,
                                identifier: String? = nil,
                                provider: @escaping () async throws -> UIImage) -> Asset<UIImage> {
        let cacheKey = identifier ?? url.lastPathComponent
        return Asset(source: url, cached: cachedImage(withIdentifier: cacheKey), provider: {
            let image = try await provider()
            if let data = image.pngData() {
                let localURL = self.makeLocalAssetURL(withIdentifier: cacheKey, pathExtension: "png")
                try? data.write(to: localURL)
            }

            objc_sync_enter(self)
            defer {
                objc_sync_exit(self)
            }

            self.imageCache.setObject(image, forKey: cacheKey as NSString)
            return image
        })
    }

    public func fetchImageAsset(at url: URL, identifier: String? = nil) -> Asset<UIImage> {
        let cacheKey = identifier ?? url.lastPathComponent
        return Asset(source: url, cached: cachedImage(withIdentifier: cacheKey), provider: {
            let localURL = try await self.download(url, identifier: cacheKey, pathExtension: url.pathExtension)
            let image = try UIImage(contentsOfFile: localURL.path).unwrap()

            objc_sync_enter(self)
            defer {
                objc_sync_exit(self)
            }

            self.imageCache.setObject(image, forKey: cacheKey as NSString)
            return image
        })
    }

    public func fetchAVAsset(at url: URL, identifier: String? = nil) -> Asset<AVAsset> {
        let cacheKey = identifier ?? url.lastPathComponent

        var pathExtension = "mp4"
        if url.pathExtension.isEmpty == false {
            pathExtension = url.pathExtension
        }

        var cachedAsset: AVAsset?
        let localURL = makeLocalAssetURL(withIdentifier: cacheKey, pathExtension: pathExtension)
        if fileManager.fileExists(atPath: localURL.path) {
            cachedAsset = AVAsset(url: localURL)
        }

        return Asset(source: url, cached: cachedAsset, provider: {
            let localURL = try await self.download(url, identifier: cacheKey, pathExtension: pathExtension)
            return AVAsset(url: localURL)
        })
    }

    public func fetchDataAsset(at url: URL, identifier: String? = nil) -> Asset<Data> {
        let cacheKey = identifier ?? url.lastPathComponent
        let localURL = makeLocalAssetURL(withIdentifier: cacheKey)
        return Asset(source: url, cached: try? Data(contentsOf: localURL), provider: {
            let localURL = try await self.download(url, identifier: cacheKey)
            return try Data(contentsOf: localURL)
        })
    }

    public func fetchURLAsset(at url: URL, identifier: String? = nil) -> Asset<URL> {
        let cacheKey = identifier ?? url.lastPathComponent
        let localURL = makeLocalAssetURL(withIdentifier: cacheKey)
        return Asset(source: url,
                     cached: fileManager.fileExists(atPath: localURL.path) ? localURL : nil,
                     provider: {
            return try await self.download(url, identifier: cacheKey)
        })
    }

    public func fetchURLAsset(at url: URL,
                              identifier: String? = nil,
                              provider: @escaping (URL) async throws -> URL) -> Asset<URL> {
        let cacheKey = identifier ?? url.lastPathComponent
        let localURL = makeLocalAssetURL(withIdentifier: cacheKey)
        return Asset(source: url,
                     cached: fileManager.fileExists(atPath: localURL.path) ? localURL : nil,
                     provider: {
            return try await provider(localURL)
        })
    }
}
