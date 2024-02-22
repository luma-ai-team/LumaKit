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
}
