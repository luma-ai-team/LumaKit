//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import CoreGraphics

public extension CGAffineTransform {

    var rotation: CGFloat {
        return atan2(Double(b), Double(a))
    }

    var scale: CGPoint {
        return .init(x: sqrt(a * a + c * c), y: sqrt(b * b + d * d))
    }

    var translation: CGPoint {
        return .init(x: tx, y: ty)
    }

    // MARK: - 

    static func scale(value: CGFloat) -> CGAffineTransform {
        return .init(scaleX: value, y: value)
    }

    func scaledBy(value: CGFloat) -> CGAffineTransform {
        return scaledBy(x: value, y: value)
    }

    mutating func transpose() {
        swap(&a, &b)
        swap(&c, &d)
    }
}
