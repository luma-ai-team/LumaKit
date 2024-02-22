//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension CALayer {

    func applyCornerRadius(value: CGFloat) {
        cornerRadius = value
        cornerCurve = .continuous
    }

    func applyMaximumCornerRadius() {
        cornerRadius = 0.5 * bounds.size.min
        cornerCurve = (bounds.aspect == 1.0) ? .circular : .continuous
    }

    func applyShadow(color: UIColor = .black,
                     radius: CGFloat = 6.0,
                     opacity: Float = 0.2,
                     offset: CGSize = .init(width: 0.0, height: 3.0),
                     path: UIBezierPath? = nil) {
        shadowColor = color.cgColor
        shadowOpacity = opacity
        shadowRadius = radius
        shadowOffset = offset
        shadowPath = path?.cgPath
    }
}
