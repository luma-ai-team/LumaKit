//
//  SnapchatShareDestination.swift
//  LumaKit
//
//  Created by Anton K on 11.03.2025.
//

import UIKit
import LumaKit

public final class SnapchatShareDestination: ShareDestination {
    enum SnapchatError: Error {
        case notInstalled
    }

    public let identifier: String = "ai.luma.kit.share.snapchat"
    public let title: String
    public let icon: UIImage?
    public var status: ShareStatus

    private let clientId: String
    private let creativeKitURLString: String = "snapchat://creativekit/preview/1"

    public init(clientId: String, title: String = "Snapchat", icon: UIImage? = nil) {
        self.clientId = clientId
        self.title = title
        self.icon = icon ?? .init(named: "icSnapchat", in: .module, compatibleWith: nil)

        if let url = URL(string: creativeKitURLString),
           let scheme = url.scheme,
           let schemes = Bundle.main.infoDictionary?["LSApplicationQueriesSchemes"] as? [String],
           schemes.contains(scheme),
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
        var components = try URLComponents(string: creativeKitURLString).unwrap()
        var items: [String: Any] = [
            "com.snapchat.creativekit.clientID": clientId
        ]

        for element in content.reversed() {
            if let _ = element.asset {
                items["com.snapchat.creativekit.backgroundVideo"] = element.data
            }
            else if let _ = element.image {
                items["com.snapchat.creativekit.backgroundImage"] = element.data
            }
            else {
                items["com.snapchat.creativekit.captionText"] = element.text
            }
        }

        let pasteboard = UIPasteboard.general
        let expirationDate = Date().addingTimeInterval(5.0 * 60.0)
        let options: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: expirationDate
        ]
        pasteboard.setItems([items], options: options)

        components.queryItems = [
            .init(name: "checkcount", value: "\(pasteboard.changeCount)"),
            .init(name: "clientId", value: clientId),
            .init(name: "appDisplayName", value: Bundle.main.appDisplayName)
        ]

        let url = try components.url.unwrap()
        guard UIApplication.shared.canOpenURL(url) else {
            throw SnapchatError.notInstalled
        }

        await UIApplication.shared.open(url)
    }
}
