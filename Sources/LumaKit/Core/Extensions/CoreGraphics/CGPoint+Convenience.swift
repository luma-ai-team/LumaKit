//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import CoreGraphics

extension CGPoint {

    public func clamped(in rect: CGRect) -> CGPoint {
        return CGPoint(
            x: x.clamped(min: rect.minX, max: rect.maxX),
            y: y.clamped(min: rect.minY, max: rect.maxY)
        )
    }

    public func clamped(min: CGPoint, max: CGPoint) -> CGPoint {
        return CGPoint(
            x: x.clamped(min: min.x, max: max.x),
            y: y.clamped(min: min.y, max: max.y)
        )
    }

    public func translated(byX x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }

    public func rounded(precision: CGFloat) -> CGPoint {
        let x = round(self.x / precision) * precision
        let y = round(self.y / precision) * precision
        return CGPoint(x: x, y: y)
    }

    public func transposed() -> CGPoint {
        return CGPoint(x: y, y: x)
    }

    public mutating func transpose() {
        swap(&x, &y)
    }

    // MARK: - Operators

    public static prefix func - (rhs: CGPoint) -> CGPoint {
        return CGPoint(x: -rhs.x, y: -rhs.y)
    }

    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func * (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
    }

    public static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    public static func / (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x / rhs.width, y: lhs.y / rhs.height)
    }

    public static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}
