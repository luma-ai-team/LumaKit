//
//  MedaProviderItem.swift
//  LumaKit
//
//  Created by Anton K on 14.04.2026.
//

import UIKit

public struct MediaProviderItem {
    public let title: String
    public let icon: UIImage?
    public let badge: String?

    public init(title: String, icon: UIImage?, badge: String? = nil) {
        self.title = title
        self.icon = icon
        self.badge = badge
    }
}
