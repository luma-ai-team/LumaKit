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
 
    override open class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    public init(gradient: Gradient = .horizontal(colors: [.clear])) {
        self.gradient = gradient
        super.init(frame: .zero)
    }

    required public init?(coder: NSCoder) {
        self.gradient = .horizontal(colors: [.clear])
        super.init(coder: coder)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }

        var colors = (isReversed ? gradient.colors.reversed() : gradient.colors)
        if colors.count == 1,
           let color = colors.first {
            colors.append(color)
        }

        let isDimmed = self.isDimmed || (isEnabled == false)
        if isDimmed {
            colors = colors.map { (color: UIColor) in
                return .init(white: 0.75 * color.yuv.y, alpha: color.alpha)
            }
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
}

