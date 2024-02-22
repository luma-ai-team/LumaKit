//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

// swiftlint:disable identifier_name
public struct RGB: Codable, Equatable {
    public var r: CGFloat
    public var g: CGFloat
    public var b: CGFloat

    public func yuv() -> YUV {
        let luminance = (0.299 * r + 0.587 * g + 0.114 * b) // BT.601
        return YUV(y: luminance, u: b - luminance, v: r - luminance)
    }

    public func cmyk() -> CMYK {
        let k = 1.0 - max(r, g, b)
        let c = (1.0 - r - k) / (1.0 - k)
        let m = (1.0 - g - k) / (1.0 - k)
        let y = (1.0 - b - k) / (1.0 - k)
        return CMYK(c: c, m: m, y: y, k: k)
    }
}

public struct HSB {
    public var h: CGFloat
    public var s: CGFloat
    public var b: CGFloat
}

public struct YUV {
    public var y: CGFloat
    public var u: CGFloat
    public var v: CGFloat
}

public struct CMYK {
    public var c: CGFloat
    public var m: CGFloat
    public var y: CGFloat
    public var k: CGFloat
}
// swiftlint:enable identifier_name

extension UIColor {
    // MARK: - Alpha

    public var alpha: CGFloat {
        var alpha: CGFloat = 0.0
        getRed(nil, green: nil, blue: nil, alpha: &alpha)
        return alpha
    }

    // MARK: - RGB

    public var rgb: RGB {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return RGB(r: red, g: green, b: blue)
    }

    // MARK: - HSB

    public var hsb: HSB {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        return HSB(h: hue, s: saturation, b: brightness)
    }

    // MARK: - YUV

    public var yuv: YUV {
        return rgb.yuv()
    }

    // MARK: - CMYK

    public var cmyk: CMYK {
        return rgb.cmyk()
    }

    public static func p3(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) -> UIColor {
        return UIColor(displayP3Red: CGFloat(red) / 255.0,
                       green: CGFloat(green) / 255.0,
                       blue: CGFloat(blue) / 255.0,
                       alpha: CGFloat(alpha) / 255.0)
    }

    public static func p3(rgb: UInt32) -> UIColor {
        return p3(red: UInt8(clamping: (rgb >> 16) & 0xFF),
                  green: UInt8(clamping: (rgb >> 8) & 0xFF),
                  blue: UInt8(clamping: (rgb >> 0) & 0xFF))
    }

    public static func p3(rgba: UInt32) -> UIColor {
        return p3(red: UInt8(clamping: (rgba >> 24) & 0xFF),
                  green: UInt8(clamping: (rgba >> 16) & 0xFF),
                  blue: UInt8(clamping: (rgba >> 8) & 0xFF),
                  alpha: UInt8(clamping: rgba & 0xFF))
    }

    public static func p3(rgb: RGB) -> UIColor {
        return UIColor(displayP3Red: rgb.r, green: rgb.g, blue: rgb.b, alpha: 1.0)
    }

    public static func srgb(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) -> UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    public static func srgb(rgb: UInt32) -> UIColor {
        return srgb(red: UInt8(clamping: (rgb >> 16) & 0xFF),
                    green: UInt8(clamping: (rgb >> 8) & 0xFF),
                    blue: UInt8(clamping: (rgb >> 0) & 0xFF))
    }

    public static func srgb(rgba: UInt32) -> UIColor {
        return srgb(red: UInt8(clamping: (rgba >> 24) & 0xFF),
                    green: UInt8(clamping: (rgba >> 16) & 0xFF),
                    blue: UInt8(clamping: (rgba >> 8) & 0xFF),
                    alpha: UInt8(clamping: rgba & 0xFF))
    }

    public static func srgb(rgb: RGB) -> UIColor {
        return UIColor(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: 1.0)
    }

    public convenience init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(alpha) / 255.0
        )
    }

    public convenience init(rgba: UInt32) {
        self.init(
            red: UInt8(clamping: (rgba >> 24) & 0xFF),
            green: UInt8(clamping: (rgba >> 16) & 0xFF),
            blue: UInt8(clamping: (rgba >> 8) & 0xFF),
            alpha: UInt8(clamping: rgba & 0xFF)
        )
    }

    public convenience init(rgb: UInt32) {
        self.init(
            red: UInt8(clamping: (rgb >> 16) & 0xFF),
            green: UInt8(clamping: (rgb >> 8) & 0xFF),
            blue: UInt8(clamping: (rgb >> 0) & 0xFF),
            alpha: 255
        )
    }

    public convenience init(rgb: RGB) {
        self.init(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: 1.0)
    }
}
