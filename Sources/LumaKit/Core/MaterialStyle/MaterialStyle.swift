//
//  MaterialStyle.swift
//  LumaKit
//
//  Created by Anton K on 02.05.2025.
//

import UIKit

public enum MaterialStyle: Equatable {
    case `default`
    case glass(tint: UIColor)
    case matte(tint: UIColor, borderAlpha: CGFloat = 0.6)
    case system(tint: UIColor? = nil)
    case systemInteractive(tint: UIColor? = nil)

    public var isDefault: Bool {
        switch self {
        case .default:
            return true
        default:
            return false
        }
    }

    public var isSystem: Bool {
        switch self {
        case .system, .systemInteractive:
            return true
        case .default, .glass, .matte:
            return false
        }
    }

    public var tintColor: UIColor? {
        switch self {
        case .default:
            return nil
        case .glass(let tint):
            return tint
        case .matte(let tint, let alpha):
            return tint.withAlphaComponent(alpha)
        case .system(let tint), .systemInteractive(let tint):
            return tint
        }
    }

    public var isInteractive: Bool {
        switch self {
        case .glass, .matte, .default, .system:
            return false
        case .systemInteractive:
            return true
        }
    }
}
