//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

extension CGSize {

    public var aspect: CGFloat {
        return width / height
    }

    public var max: CGFloat {
        return Swift.max(width, height)
    }

    public var min: CGFloat {
        return Swift.min(width, height)
    }

    public static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    public static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }

    public static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }

    public static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }

    public static func - (lhs: CGSize, rhs: UIEdgeInsets) -> CGSize {
        return CGSize(width: lhs.width - rhs.left - rhs.right,
                      height: lhs.height - rhs.top - rhs.bottom)
    }

    public static func + (lhs: CGSize, rhs: UIEdgeInsets) -> CGSize {
        return CGSize(width: lhs.width + rhs.left + rhs.right,
                      height: lhs.height + rhs.top + rhs.bottom)
    }

    public func abs() -> CGSize {
        return .init(width: Swift.abs(width), height: Swift.abs(height))
    }

    public func insetBy(dx: CGFloat, dy: CGFloat) -> CGSize {
        return .init(width: width - dx, height: height - dy)
    }

    public func transposed() -> CGSize {
        return CGSize(width: height, height: width)
    }
}
