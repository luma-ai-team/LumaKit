//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import CoreGraphics

extension CGRect {

    public var aspect: CGFloat {
        return size.aspect
    }

    public var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }

    public var isIndefenite: Bool {
        return minX.isNaN || minY.isNaN || width.isNaN || height.isNaN
    }

    // MARK: - Edges

    public var topLeft: CGPoint {
        return origin
    }

    public var topMiddle: CGPoint {
        return CGPoint(x: midX, y: minY)
    }

    public var topRight: CGPoint {
        return CGPoint(x: maxX, y: minY)
    }

    public var middleLeft: CGPoint {
        return CGPoint(x: minX, y: midY)
    }

    public var middleRight: CGPoint {
        return CGPoint(x: maxX, y: midY)
    }

    public var bottomLeft: CGPoint {
        return CGPoint(x: minX, y: maxY)
    }

    public var bottomMiddle: CGPoint {
        return CGPoint(x: midX, y: maxY)
    }

    public var bottomRight: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }

    public static func * (lhs: CGRect, rhs: CGSize) -> CGRect {
        return CGRect(x: lhs.minX * rhs.width,
                      y: lhs.minY * rhs.height,
                      width: lhs.width * rhs.width,
                      height: lhs.height * rhs.height)
    }

    public static func * (lhs: CGRect, rhs: CGFloat) -> CGRect {
        return CGRect(x: lhs.minX * rhs,
                      y: lhs.minY * rhs,
                      width: lhs.width * rhs,
                      height: lhs.height * rhs)
    }

    // MARK: - Initializers

    public init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2.0,
                  y: center.y - size.height / 2.0,
                  width: size.width,
                  height: size.height)
    }

    public init(topLeft: CGPoint, bottomRight: CGPoint) {
        let size = CGSize(width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y)
        self.init(origin: topLeft, size: size)
    }

    public init(filling target: CGRect, aspect: CGFloat) {
        self.init()
        size = CGSize(width: aspect, height: 1.0)
        fill(rect: target)
    }

    public init(fitting target: CGRect, aspect: CGFloat) {
        self.init()
        size = CGSize(width: aspect, height: 1.0)
        fit(rect: target)
    }

    public init(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) {
        self.init(x: left, y: top, width: right - left, height: bottom - top)
    }

    public static func reference() -> CGRect {
        return CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
    }

    // MARK: Fit / Fill

    public func scaleToFit(rect: CGRect) -> CGFloat {
        let scale = rect.width / width
        if height * scale <= rect.height {
            return scale
        }

        return rect.height / height
    }

    public func scaleToFill(rect: CGRect) -> CGFloat {
        return 1.0 / rect.scaleToFit(rect: self)
    }

    public mutating func fit(rect: CGRect) {
        let scale = scaleToFit(rect: rect)
        size.width = width * scale
        size.height = height * scale
        origin.x = rect.midX - width / 2.0
        origin.y = rect.midY - height / 2.0
    }

    public func fitting(rect: CGRect) -> CGRect {
        var result = self
        result.fit(rect: rect)
        return result
    }

    public mutating func fill(rect: CGRect) {
        let scale = scaleToFill(rect: rect)
        size.width = width * scale
        size.height = height * scale
        origin.x = rect.midX - width / 2.0
        origin.y = rect.midY - height / 2.0
    }

    public func filling(rect: CGRect) -> CGRect {
        var result = self
        result.fill(rect: rect)
        return result
    }

    // MARK: - Alignment

    public func alignedForVideoExport() -> CGRect {
        let alignment: CGFloat = 16.0
        let alignedWidth = floor(width / alignment) * alignment
        let alignedHeight = round(0.5 * alignedWidth / aspect) * 2.0
        return CGRect(x: minX, y: minY, width: alignedWidth, height: alignedHeight)
    }

    // MARK: - Scale

    public func scaled(byX x: CGFloat, y: CGFloat) -> CGRect {
        let width = self.width * x
        let height = self.height * y
        return CGRect(x: center.x - 0.5 * width, y: center.y - 0.5 * height, width: width, height: height)
    }

    // MARK: - Translation

    public func translated(byX x: CGFloat, y: CGFloat) -> CGRect {
        return CGRect(x: minX + x, y: minY + y, width: width, height: height)
    }

    // MARK: - Transpose

    public mutating func transpose() {
        swap(&origin.x, &origin.y)
        swap(&size.width, &size.height)
    }
}
