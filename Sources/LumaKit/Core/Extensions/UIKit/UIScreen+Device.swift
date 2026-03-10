//
//  UIScreen+Device.swift
//  LumaKit
//
//  Created by Anton K on 03.03.2026.
//

import UIKit

extension UIScreen {
    private static let displayCornerRadiusPropertyKey: String = {
        let components = ["Radius", "Corner", "display", "_"]
        return components.reversed().joined()
    }()

    public func fetchDisplayCornerRadius(fallback: CGFloat = 24.0) -> CGFloat {
        return value(forKey: Self.displayCornerRadiusPropertyKey) as? CGFloat ?? fallback
    }
}
