//
//  FacebookShareDestination.swift
//  LumaKit
//
//  Created by Anton K on 11.03.2025.
//

import UIKit
import LumaKit

public final class FacebookShareDestination: ShareDestination {
    public let identifier: String = "ai.luma.kit.share.facebook"
    public let title: String
    public let icon: UIImage?
    public var status: ShareStatus

    public init(title: String = "Facebook", icon: UIImage? = nil) {
        self.title = title
        self.icon = icon ?? .init(named: "icFacebook", in: .module, compatibleWith: nil)
        self.status = .available
    }

    public func canShare(_ content: [ShareContent]) -> Bool {
        return false
    }

    public func share(_ content: [ShareContent], in context: ShareContext) async throws {

    }
}
