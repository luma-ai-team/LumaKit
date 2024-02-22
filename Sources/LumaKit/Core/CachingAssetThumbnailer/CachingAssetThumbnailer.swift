//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit
import AVFoundation

public final class CachingAssetThumbnailer {
    private static var cache: NSCache<NSString, CGImage> = .init()
    private static var queue: DispatchQueue = .init(label: "lumakit.thumbnailer")
    private static var context: CIContext = .init()

    private(set) var asset: AVAsset
    private var generator: AVAssetImageGenerator?
    private var content: CIImage?

    public var maximumSize: CGSize = .init(width: 120.0, height: 120.0) {
        didSet {
            generator = nil
        }
    }

    public init(asset: AVAsset) {
        self.asset = asset
    }

    private func prepareImageGenerator() -> AVAssetImageGenerator? {
        if generator?.asset == asset {
            return generator
        }

        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = maximumSize
        self.generator = generator
        return generator
    }

    @discardableResult
    public func update(with asset: AVAsset) -> Bool {
        self.asset = asset
        return generator !== prepareImageGenerator()
    }

    public func fetchImage(at time: CMTime) -> CGImage? {
        return Self.queue.sync {
            let cacheKey = self.makeCacheKey(for: time)
            if let image = Self.cache.object(forKey: cacheKey) {
                return image
            }

            let image = try? prepareImageGenerator()?.copyCGImage(at: time, actualTime: nil)
            if let image = image {
                Self.cache.setObject(image, forKey: cacheKey)
            }

            return image
        }
    }

    private func makeCacheKey(for time: CMTime) -> NSString {
        let assetKey: String = Unmanaged.passUnretained(asset).toOpaque().debugDescription
        return "\(assetKey)-\(time.seconds)-\(maximumSize)" as NSString
    }
}
