//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

// MARK: - ColorPair

public final class ColorPair {
    public let primary: UIColor
    public let secondary: UIColor

    public init(color: UIColor) {
        primary = color
        secondary = color
    }

    public init(primary: UIColor, secondary: UIColor) {
        self.primary = primary
        self.secondary = secondary
    }
}

// MARK: - GradientPair

public final class GradientPair {
    public let active: Gradient
    public let inactive: Gradient

    public init(gradient: Gradient) {
        active = gradient
        inactive = gradient.dimmed()
    }

    public init(active: Gradient, inactive: Gradient) {
        self.active = active
        self.inactive = inactive
    }
}

// MARK: - ActionColor

public final class ActionColor {
    public let active: UIColor
    public let inactive: UIColor
    public let disabled: UIColor

    public init(color: UIColor) {
        active = color
        inactive = color.withAlphaComponent(0.5)
        disabled = color.withAlphaComponent(0.5)
    }

    public init(active: UIColor, inactive: UIColor) {
        self.active = active
        self.inactive = inactive
        disabled = inactive
    }

    public init(active: UIColor, inactive: UIColor, disabled: UIColor) {
        self.active = active
        self.inactive = inactive
        self.disabled = disabled
    }
}

// MARK: - ColorScheme

public final class ColorScheme {
    public var background: ColorPair = .init(primary: .white, secondary: .init(white: 0.9, alpha: 1.0))
    public var foreground: ColorPair = .init(primary: .black, secondary: .darkGray)
    public var genericAction: ActionColor = .init(active: .black, inactive: .lightGray)
    public var premiumAction: ActionColor = .init(color: .white)
    public var destructiveAction: ActionColor = .init(color: .systemRed)
    public var gradient: GradientPair = .init(gradient: .horizontal(colors: [.lightGray, .darkGray]))

    public init() {}
}

