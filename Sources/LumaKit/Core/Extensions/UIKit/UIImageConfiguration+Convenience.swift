//
//  UIImageConfiguration+Convenience.swift
//  LumaKit
//
//  Created by Anton Kormakov on 13.11.2024.
//

import UIKit

public extension UIImage.Configuration {
    static func symbol(size: CGFloat,
                       weight: UIImage.SymbolWeight = .regular,
                       palette: [UIColor]? = nil) -> UIImage.SymbolConfiguration {
        var configuration = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
        if let palette = palette {
            let colorConfiguration = UIImage.SymbolConfiguration(paletteColors: palette)
            configuration = configuration.applying(colorConfiguration)
        }

        return configuration
    }
}
