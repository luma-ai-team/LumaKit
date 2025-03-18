//
//  InstgramShareDestination.swift
//  LumaKit
//
//  Created by Anton K on 11.03.2025.
//

import UIKit
import LumaKit

public final class InstagramShareDestination: ShareDestination {
    enum InstagramError: Error {
        case notInstalled
    }

    public let identifier: String = "ai.luma.kit.share.instagram"
    public let title: String
    public let icon: UIImage?
    public var status: ShareStatus

    private let clientId: String
    let appURLString: String = "instagram-stories://share"

    public init(clientId: String, title: String = "Instagram", icon: UIImage? = nil) {
        self.clientId = clientId
        self.title = title
        self.icon = icon ?? .init(named: "icInstagram", in: .module, compatibleWith: nil)

        if let url = URL(string: appURLString),
           UIApplication.shared.canOpenURL(url) {
            status = .available
        }
        else {
            status = .unavailable
        }
    }

    public func canShare(_ content: [ShareContent]) -> Bool {
        return content.contains(with: true, at: \.isMedia)
    }

    public func share(_ content: [ShareContent], in context: ShareContext) async throws {
        var items: [String: Any] = [
            "com.instagram.sharedSticker.appID": clientId
        ]

        for element in content.reversed() {
            if let _ = element.asset {
                items["com.instagram.sharedSticker.backgroundVideo"] = element.data
            }
            else if let _ = element.image {
                items["com.instagram.sharedSticker.backgroundImage"] = element.data
            }
        }

        let pasteboard = UIPasteboard.general
        let expirationDate = Date().addingTimeInterval(5.0 * 60.0)
        let options: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: expirationDate
        ]
        pasteboard.setItems([items], options: options)

        var components = try URLComponents(string: appURLString).unwrap()
        components.queryItems = [
            .init(name: "source_application", value: clientId)
        ]
        let url = try components.url.unwrap()
        guard UIApplication.shared.canOpenURL(url) else {
            throw InstagramError.notInstalled
        }

        await UIApplication.shared.open(url)
    }
}
