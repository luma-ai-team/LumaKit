//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class AnimatedGradientView: GradientView {

    public override var gradient: Gradient {
        didSet {
            intermediates = makeIntermediates(for: gradient)
        }
    }

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

    public override init(gradient: Gradient = .horizontal(colors: [.clear])) {
        super.init(gradient: gradient)
        intermediates = makeIntermediates(for: gradient)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

    private func makeIntermediates(for gradient: Gradient) -> [Gradient] {
        let intermediateCount = gradient.colors.count - 1
        var intermediates: [Gradient] = []
        for index in stride(from: 0, to: intermediateCount, by: 1) {
            intermediates.append(gradient.shifted(delta: index + 1))
        }

        return intermediates
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
