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
    case matte(tint: UIColor)

    public var isDefault: Bool {
        switch self {
        case .default:
            return true
        default:
            return false
        }
    }
}
