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
        applyBounceAnimation(style: bounceStyle)
    }

    private func applyDiagonalShimmer() {
        shimmerLayer.removeAllAnimations()
        shimmerLayer.colors = [
            shimmerColor.withAlphaComponent(0.0).cgColor,
            shimmerColor.withAlphaComponent(0.0).cgColor,
            shimmerColor.withAlphaComponent(0.1).cgColor,
            shimmerColor.withAlphaComponent(0.6).cgColor,
            shimmerColor.withAlphaComponent(0.1).cgColor,
            shimmerColor.withAlphaComponent(0.0).cgColor,
            shimmerColor.withAlphaComponent(0.0).cgColor
        ]

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
}

