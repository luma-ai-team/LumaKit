//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class AnimatedGradientView: GradientView {

    open var intermediates: [Gradient] = [] {
        didSet {
            updateAnimation()
        }
    }

    open var stepDuration: TimeInterval = 0.5 {
        didSet {
            updateAnimation()
        }
    }

    open private(set) var isAnimating: Bool = false

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateAnimation()
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()
        updateAnimation()
    }

    open override func tintColorDidChange() {
        super.tintColorDidChange()
        updateAnimation()
    }

    func updateAnimation() {
        layer.removeAllAnimations()
        guard isDimmed == false,
              isAnimating else {
            return
        }

        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }

        let gradients = [gradient] + intermediates + [gradient]
        let colorCount = max(gradients.sorted(by: \.colors.count).last?.colors.count ?? 1, 2)

        let animation = CAKeyframeAnimation(keyPath: "colors")
        animation.values = gradients.map { (graident: Gradient) in
            return graident.breakdown(count: colorCount).map(\.cgColor)
        }

        animation.duration = stepDuration * TimeInterval(gradients.count)
        animation.calculationMode = .linear
        animation.repeatCount = .greatestFiniteMagnitude
        animation.isRemovedOnCompletion = false
        gradientLayer.add(animation, forKey: animation.keyPath)
    }

    open func startAnimating() {
        isAnimating = true
        updateAnimation()
    }

    open func stopAnimating() {
        isAnimating = false
        updateAnimation()
    }
}
