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

    public var isGlass: Bool {
        switch self {
        case .glass:
            return true
        default:
            return false
        }
    }
}
