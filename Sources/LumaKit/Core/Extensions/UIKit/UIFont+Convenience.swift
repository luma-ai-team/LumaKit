//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension UIFont {
    static func roundedSystemFont(ofSize size: CGFloat, weight: Weight) -> UIFont {
        let font: UIFont = .systemFont(ofSize: size, weight: weight)
        guard let descriptor = font.fontDescriptor.withDesign(.rounded) else {
            return font
        }

        return .init(descriptor: descriptor, size: font.pointSize)
    }

    static func compatibleSystemFont(ofSize size: CGFloat, weight: Weight, width: Width) -> UIFont {
        if #available(iOS 16.0, *) {
            return .systemFont(ofSize: size, weight: weight, width: width)
        } else {
            return .systemFont(ofSize: size, weight: weight)
        }
    }
}
