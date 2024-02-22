//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension UIView {
    func applyCornerRadius(value: CGFloat) {
        layer.applyCornerRadius(value: value)
    }

    func applyMaximumCornerRadius() {
        layer.applyMaximumCornerRadius()
    }

    func applyShadow(color: UIColor = .black,
                     radius: CGFloat = 6.0,
                     opacity: Float = 0.2,
                     offset: CGSize = .init(width: 0.0, height: 3.0),
                     path: UIBezierPath? = nil) {
        layer.applyShadow(color: color, radius: radius, opacity: opacity, offset: offset, path: path)
    }
}
