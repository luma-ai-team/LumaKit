//
//  UIApplication+Convenience.swift
//
//
//  Created by Anton Kormakov on 23.07.2024.
//

import UIKit

public extension UIApplication {

    var activeWindow: UIWindow {
        let windowScenes = connectedScenes.compactMap { (scene: UIScene) in
            return scene as? UIWindowScene
        }

        return windowScenes.first?.keyWindow ?? .init()
    }
}
