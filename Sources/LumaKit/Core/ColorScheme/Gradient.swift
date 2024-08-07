//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public struct Gradient: Codable {
    enum CodingKeys: CodingKey {
        case startPoint
        case endPoint
        case colors
        case locations
    }

    public var startPoint: CGPoint
    public var endPoint: CGPoint
    public var colors: [UIColor]
    public var locations: [Double]?

    public static func horizontal(colors: [UIColor], locations: [Double]? = nil) -> Gradient {
        return .init(startPoint: .init(x: 0.0, y: 0.5),
                     endPoint: .init(x: 1.0, y: 0.5),
                     colors: colors,
                     locations: locations)
    }

    public static func vertical(colors: [UIColor], locations: [Double]? = nil) -> Gradient {
        return .init(startPoint: .init(x: 0.5, y: 0.0),
                     endPoint: .init(x: 0.5, y: 1.0),
                     colors: colors,
                     locations: locations)
    }

    public static func diagonalLTR(colors: [UIColor], locations: [Double]? = nil) -> Gradient {
        return .init(startPoint: .init(x: 0.0, y: 0.0),
                     endPoint: .init(x: 1.0, y: 1.0),
                     colors: colors,
                     locations: locations)
    }

    public static func diagonalRTL(colors: [UIColor], locations: [Double]? = nil) -> Gradient {
        return .init(startPoint: .init(x: 1.0, y: 0.0),
                     endPoint: .init(x: 0.0, y: 1.0),
                     colors: colors,
                     locations: locations)
    }

    public init(startPoint: CGPoint, endPoint: CGPoint, colors: [UIColor], locations: [Double]? = nil) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.colors = colors
        self.locations = locations
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startPoint = try container.decode(CGPoint.self, forKey: .startPoint)
        endPoint = try container.decode(CGPoint.self, forKey: .endPoint)

        let colorStrings = try container.decode([String].self, forKey: .colors)
        colors = colorStrings.compactMap { (value: String) in
            return .init(string: value)
        }

        locations = try container.decodeIfPresent([Double].self, forKey: .locations)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startPoint, forKey: .startPoint)
        try container.encode(endPoint, forKey: .endPoint)
        try container.encode(colors.map(\.stringRepresentation), forKey: .colors)
        try container.encodeIfPresent(locations, forKey: .locations)
    }

    public func color(atOffset offset: Float) -> UIColor? {
        let offset = offset.clamped(min: 0.0, max: 1.0)

        let maxIndex = Float(colors.count - 1)
        let position = offset * maxIndex

        let previousIndex = Int(offset * maxIndex)
        guard let previousColor = colors[safe: previousIndex] else {
            return nil
        }

        let nextIndex = Int(ceil(offset * maxIndex))
        guard let nextColor = colors[safe: nextIndex] else {
            return nil
        }

        let crossfade = CGFloat(position - Float(previousIndex))
        let red = previousColor.rgb.r * (1.0 - crossfade) + nextColor.rgb.r * crossfade
        let green = previousColor.rgb.g * (1.0 - crossfade) + nextColor.rgb.g * crossfade
        let blue = previousColor.rgb.b * (1.0 - crossfade) + nextColor.rgb.b * crossfade
        let alpha = previousColor.alpha * (1.0 - crossfade) + nextColor.alpha * crossfade
        return .init(red: red, green: green, blue: blue, alpha: alpha)
    }

    public func breakdown(count: Int) -> [UIColor] {
        guard count > 1 else {
            return .init(colors.prefix(count))
        }

        return stride(from: 0, to: count, by: 1).compactMap { (index: Int) in
            let offset = (Float(index) / Float(count - 1))
            return color(atOffset: offset)
        }
    }

    public func resolveLocations() -> [Double] {
        if let locations = locations {
            return locations
        }

        let count = colors.count
        let step = 1.0 / (Double(count) - 1)
        return Array(stride(from: 0.0, through: 1.0, by: step))
    }

    public func shifted(delta: Int) -> Gradient {
        var colors: [UIColor] = colors
        for _ in stride(from: 0, to: delta, by: 1) {
            colors.shiftRight()
        }
        for _ in stride(from: 0, to: delta, by: -1) {
            colors.shiftLeft()
        }

        return .init(startPoint: startPoint, endPoint: endPoint, colors: colors, locations: locations)
    }
}
