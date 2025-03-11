//
//  ShareContent.swift
//  LumaKit
//
//  Created by Anton K on 03.03.2025.
//

import UIKit
import AVFoundation

public enum ShareContent: Equatable {
    case text(String)
    case image(UIImage)
    case url(URL)

    var any: Any {
        switch self {
        case .text(let text):
            return text
        case .image(let image):
            return image
        case .url(let url):
            return url
        }
    }

    var text: String? {
        switch self {
        case .text(let text):
            return text
        case .image:
            return nil
        case .url(let url):
            return url.absoluteString
        }
    }

    var image: UIImage? {
        switch self {
        case .text:
            return nil
        case .image(let image):
            return image
        case .url(let url):
            return UIImage(contentsOfFile: url.path)
        }
    }

    var asset: AVAsset? {
        switch self {
        case .text:
            return nil
        case .image:
            return nil
        case .url(let url):
            let asset = AVURLAsset(url: url)
            guard asset.tracks.isEmpty == false else {
                return nil
            }

            return asset
        }
    }

    var url: URL? {
        switch self {
        case .text:
            return nil
        case .image:
            return nil
        case .url(let url):
            return url
        }
    }

    var data: Data? {
        switch self {
        case .text(let text):
            return text.data(using: .utf8)
        case .image(let image):
            return image.pngData()
        case .url(let url):
            return try? Data(contentsOf: url)
        }
    }
}
