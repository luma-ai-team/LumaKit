//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class ShimmerButton: GradientButton {

    public var bounceStyle: BounceAnimationStyle = .medium {
        didSet {
            layout()
        }
    }

    public var shimmerColor: UIColor = .white {
        didSet {
            layout()
        }
    }

    open override var isEnabled: Bool {
        didSet {
            updateShimmerColor()
            shimmerLayer.isHidden = isEnabled == false
        }
    }

    private lazy var shimmerLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        return layer
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        layer.addSublayer(shimmerLayer)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        shimmerLayer.frame = bounds
        applyDiagonalShimmer()
        applyBounceAnimation(style: isEnabled ? bounceStyle : .none)
    }

    private func applyDiagonalShimmer() {
        shimmerLayer.removeAllAnimations()
        guard isEnabled else {
            return
        }

        updateShimmerColor()

        shimmerLayer.startPoint = .init(x: 0.0, y: 0.0)
        shimmerLayer.endPoint = .init(x: 1.0, y: 0.15)

        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -bounds.width
        animation.toValue = bounds.width
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = 2.5
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        shimmerLayer.add(animation, forKey: animation.keyPath)
    }

    private func updateShimmerColor() {
        let isDimmed = self.isDimmed || (isEnabled == false)
        let color = isDimmed ?
            UIColor(white: shimmerColor.yuv.y, alpha: shimmerColor.alpha) :
            shimmerColor

        shimmerLayer.colors = [
            color.withAlphaComponent(0.0).cgColor,
            color.withAlphaComponent(0.0).cgColor,
            color.withAlphaComponent(0.1).cgColor,
            color.withAlphaComponent(0.6).cgColor,
            color.withAlphaComponent(0.1).cgColor,
            color.withAlphaComponent(0.0).cgColor,
            color.withAlphaComponent(0.0).cgColor
        ]
    }

    open override func tintColorDidChange() {
        super.tintColorDidChange()
        updateShimmerColor()
    }
}

