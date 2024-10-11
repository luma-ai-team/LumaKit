//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class GradientView: UIView {

   public var isReversed: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }

    public var isEnabled: Bool = true {
        didSet {
            layout()
        }
    }

    public var gradient: Gradient {
        didSet {
            setNeedsLayout()
        }
    }

    public var dimmedGradient: Gradient? {
        didSet {
            setNeedsLayout()
        }
    }

    override open class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    public init(gradient: GradientPair) {
        self.gradient = gradient.active
        self.dimmedGradient = gradient.inactive
        super.init(frame: .zero)
    }

    public init(gradient: Gradient = .solid(color: .clear)) {
        self.gradient = gradient
        super.init(frame: .zero)
    }

    required public init?(coder: NSCoder) {
        self.gradient = .solid(color: .clear)
        super.init(coder: coder)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }

        let isDimmed = self.isDimmed || (isEnabled == false)

        let gradient: Gradient
        if isDimmed {
            gradient = dimmedGradient ?? self.gradient.dimmed()
        }
        else {
            gradient = self.gradient
        }

        var colors = (isReversed ? gradient.colors.reversed() : gradient.colors)
        if colors.count == 1,
           let color = colors.first {
            colors.append(color)
        }

        gradientLayer.colors = colors.map(\.cgColor)
        gradientLayer.startPoint = gradient.startPoint
        gradientLayer.endPoint = gradient.endPoint
        gradientLayer.locations = gradient.locations?.map(NSNumber.init)
    }

    open override func tintColorDidChange() {
        super.tintColorDidChange()
        layout()
    }

    public func update(with gradientPair: GradientPair) {
        gradient = gradientPair.active
        dimmedGradient = gradientPair.inactive
    }
}

