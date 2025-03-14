//
//  TikTokShareDestination.swift
//  LumaKit
//
//  Created by Anton K on 11.03.2025.
//

import UIKit
import LumaKit
import TikTokOpenShareSDK

public final class TikTokShareDestination: ShareDestination {
    enum TikTokError: Error {
        case notInstalled
    }

    public let identifier: String = "ai.luma.kit.share.tiktok"
    public let title: String
    public let icon: UIImage?
    public var status: ShareStatus

    private let clientId: String
    private let callbackURLScheme: String
    private let tikTokURLSchemes: [String] = [
        "tiktokopensdk", "tiktoksharesdk", "snssdk1180", "snssdk1233"
    ]

    public init(clientId: String, title: String = "TikTok", icon: UIImage? = nil) {
        self.clientId = clientId
        self.title = title
        self.icon = icon ?? .init(named: "icTikTok", in: .module, compatibleWith: nil)

        let isTikTokAvailable = tikTokURLSchemes.allSatisfy { (scheme: String) in
            guard let url = URL(string: "\(scheme)://") else {
                return false
            }

            return UIApplication.shared.canOpenURL(url)
        }

        if isTikTokAvailable,
           let types = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]],
           let schemes = types.first?["CFBundleURLSchemes"] as? [String],
           let scheme = schemes.first {
            callbackURLScheme = scheme
            status = .available
        }
        else {
            callbackURLScheme = .init()
            status = .unavailable
        }
    }

    public func canShare(_ content: [ShareContent]) -> Bool {
        return content.contains(with: true, at: \.isMedia)
    }

    public func share(_ content: [ShareContent], in context: ShareContext) async throws {
        if context.assetIdentifiers == nil {
            try await PhotoLibraryShareDestination().share(content, in: context)
        }

        let identifiers = try context.assetIdentifiers.unwrap()
        let mediaType: TikTokShareMediaType = {
            for element in content {
                if let _ = element.asset {
                    return .video
                }
                else if let _ = element.image {
                    return .image
                }
            }

            return .video
        }()


        let request = TikTokShareRequest(localIdentifiers: identifiers,
                                         mediaType: mediaType,
                                         redirectURI: "\(callbackURLScheme)://tiktok")
        request.customConfig = .init(clientKey: clientId, callerUrlScheme: callbackURLScheme)
        guard request.send() else {
            throw TikTokError.notInstalled
        }
    }
}
