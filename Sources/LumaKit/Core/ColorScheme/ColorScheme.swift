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

// MARK: - ColorSet

public final class ColorSet {
    public let primary: UIColor
    public let secondary: UIColor
    public let tertiary: UIColor
    public let inactive: UIColor

    public init(color: UIColor) {
        primary = color
        secondary = color
        tertiary = color
        inactive = color.withAlphaComponent(0.5)
    }

    public init(primary: UIColor, secondary: UIColor, tertiary: UIColor? = nil, inactive: UIColor? = nil) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary ?? secondary
        self.inactive = inactive ?? secondary.withAlphaComponent(0.5)
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

    public func variant(with color: UIColor) -> ActionColor {
        return .init(active: color, inactive: inactive, disabled: disabled)
    }
}

// MARK: - ColorScheme

public final class ColorScheme {

    @MainActor
    public static var system: ColorScheme = {
        let colorScheme = ColorScheme()
        colorScheme.background = .init(primary: .systemBackground, secondary: .secondarySystemBackground)
        colorScheme.foreground = .init(primary: .label, secondary: .secondaryLabel, tertiary: .systemBackground)
        colorScheme.genericAction = .init(color: .tertiarySystemBackground)
        colorScheme.primaryAction = colorScheme.genericAction.variant(with: .systemBlue)
        colorScheme.destructiveAction = colorScheme.genericAction.variant(with: .systemRed)
        colorScheme.stroke = .init(color: .secondarySystemFill)
        return colorScheme
    }()

    @MainActor
    public static func makeFromAssetCatalog(in bundle: Bundle = .main,
                                            compatibleWith traitCollection: UITraitCollection? = nil) throws -> ColorScheme {
        let colorScheme = ColorScheme()

        let primaryBackgroundColor = try UIColor(named: "background.primary", in: bundle, compatibleWith: traitCollection).unwrap()
        let secondaryBackgroundColor = try UIColor(named: "background.secondary", in: bundle, compatibleWith: traitCollection).unwrap()
        colorScheme.background = .init(primary: primaryBackgroundColor, secondary: secondaryBackgroundColor)

        let primaryForegroundColor = try UIColor(named: "foreground.primary", in: bundle, compatibleWith: traitCollection).unwrap()
        let secondaryForegroundColor = try UIColor(named: "foreground.secondary", in: bundle, compatibleWith: traitCollection).unwrap()
        let tertiaryForegroundColor = UIColor(named: "foreground.tertiary", in: bundle, compatibleWith: traitCollection)
        let inactiveForegroundColor = UIColor(named: "foreground.inactive", in: bundle, compatibleWith: traitCollection)
        colorScheme.foreground = .init(primary: primaryForegroundColor,
                                       secondary: secondaryForegroundColor,
                                       tertiary: tertiaryForegroundColor,
                                       inactive: inactiveForegroundColor)

        let genericActiveActionColor = try UIColor(named: "action.generic.active", in: bundle, compatibleWith: traitCollection).unwrap()
        let genericInactiveActionColor = try UIColor(named: "action.generic.inactive", in: bundle, compatibleWith: traitCollection).unwrap()
        let genericDisabledActionColor = try UIColor(named: "action.generic.disabled", in: bundle, compatibleWith: traitCollection).unwrap()
        colorScheme.genericAction = .init(active: genericActiveActionColor,
                                          inactive: genericInactiveActionColor,
                                          disabled: genericDisabledActionColor)

        let primaryActiveActionColor = try UIColor(named: "action.primary.active", in: bundle, compatibleWith: traitCollection).unwrap()
        let primaryInactiveActionColor = UIColor(named: "action.primary.inactive", in: bundle, compatibleWith: traitCollection)
        let primaryDisabledActionColor = UIColor(named: "action.primary.disabled", in: bundle, compatibleWith: traitCollection)
        colorScheme.primaryAction = .init(active: primaryActiveActionColor,
                                          inactive: primaryInactiveActionColor ?? genericInactiveActionColor,
                                          disabled: primaryDisabledActionColor ?? genericDisabledActionColor)

        let destructiveActiveActionColor = try UIColor(named: "action.destructive.active", in: bundle, compatibleWith: traitCollection).unwrap()
        let destructiveInactiveActionColor = UIColor(named: "action.destructive.inactive", in: bundle, compatibleWith: traitCollection)
        let destructiveDisabledActionColor = UIColor(named: "action.destructive.disabled", in: bundle, compatibleWith: traitCollection)
        colorScheme.destructiveAction = .init(active: destructiveActiveActionColor,
                                              inactive: destructiveInactiveActionColor ?? genericInactiveActionColor,
                                              disabled: destructiveDisabledActionColor ?? genericDisabledActionColor)

        let primaryStrokeColor = try UIColor(named: "stroke.primary", in: bundle, compatibleWith: traitCollection).unwrap()
        let secondaryStrokeColor = UIColor(named: "stroke.secondary", in: bundle, compatibleWith: traitCollection)
        let tertiaryStrokeColor = UIColor(named: "stroke.tertiary", in: bundle, compatibleWith: traitCollection)
        let inactiveStrokeColor = UIColor(named: "stroke.inactive", in: bundle, compatibleWith: traitCollection)
        colorScheme.stroke = .init(primary: primaryStrokeColor,
                                   secondary: secondaryStrokeColor ?? primaryStrokeColor,
                                   tertiary: tertiaryStrokeColor,
                                   inactive: inactiveStrokeColor)

        let activeGradientStartColor = try UIColor(named: "gradient.active.start", in: bundle, compatibleWith: traitCollection).unwrap()
        let activeGradientEndColor = UIColor(named: "gradient.active.end", in: bundle, compatibleWith: traitCollection)
        let activeGradient: Gradient = .horizontal(colors: [
            activeGradientStartColor, activeGradientEndColor ?? activeGradientStartColor
        ])

        let inactiveGradientStartColor = try UIColor(named: "gradient.inactive.start", in: bundle, compatibleWith: traitCollection).unwrap()
        let inactiveGradientEndColor = UIColor(named: "gradient.inactive.end", in: bundle, compatibleWith: traitCollection)
        let inactiveGradient: Gradient = .horizontal(colors: [
            inactiveGradientStartColor, inactiveGradientEndColor ?? inactiveGradientStartColor
        ])

        colorScheme.gradient = .init(active: activeGradient, inactive: inactiveGradient)
        return colorScheme
    }

    @available(*, deprecated, renamed: "primaryAction", message: "Use primaryAction instead")
    public var premiumAction: ActionColor {
        return primaryAction
    }

    public var background: ColorPair = .init(primary: .init(white: 0.9, alpha: 1.0), secondary: .white)
    public var foreground: ColorSet = .init(primary: .black, secondary: .darkGray)
    public var primaryAction: ActionColor = .init(color: .white)
    public var genericAction: ActionColor = .init(active: .systemBlue, inactive: .lightGray)
    public var destructiveAction: ActionColor = .init(color: .systemRed)
    public var stroke: ColorSet = .init(color: .lightGray)
    public var gradient: GradientPair = .init(gradient: .horizontal(colors: [.lightGray, .darkGray]))

    public init() {}
}

