//
//  WhatsAppShareDestination.swift
//  LumaKit
//
//  Created by Anton K on 11.03.2025.
//

import UIKit
import LumaKit

public final class WhatsAppShareDestination: ShareDestination {
    public let identifier: String = "ai.luma.kit.share.whatsapp"
    public let title: String
    public let icon: UIImage?
    public var status: ShareStatus

    public init(title: String = "WhatsApp", icon: UIImage? = nil) {
        self.title = title
        self.icon = icon ?? .init(named: "icWhatsApp", in: .module, compatibleWith: nil)
        self.status = .available
    }

    public func canShare(_ content: [ShareContent]) -> Bool {
        return content.contains { (content: ShareContent) in
            return content.text != nil ||
                   content.url != nil
        }
    }

    public func share(_ content: [ShareContent], in context: ShareContext) async throws {
        let elements = content.compactMap { (content: ShareContent) in
            return content.text
        }
        let query = elements.joined(separator: " ")

        var components = URLComponents()
        components.scheme = "https"
        components.host = "wa.me"
        components.path = "/"
        components.queryItems = [
            .init(name: "text", value: query)
        ]

        let url = try components.url.unwrap()
        await UIApplication.shared.open(url)
    }
}
