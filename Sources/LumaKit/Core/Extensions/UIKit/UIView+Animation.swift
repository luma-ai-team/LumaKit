//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension UIView {

    var isDimmed: Bool {
        return tintAdjustmentMode == .dimmed
    }

    // MARK: - Bounce Animation

    enum BounceAnimationStyle: CGFloat {
        case soft = 0.01
        case medium = 0.03
        case heavy = 0.05
        case none = 0
    }

    func applyBounceAnimation(style: BounceAnimationStyle = .heavy,
                              delay: TimeInterval = 1.0,
                              pause: TimeInterval = 1.0,
                              repeats: Bool = true) {
        let animationKey = "bounce"
        guard style != .none else {
            removeBounceAnimation()
            return
        }

        let steps: [TimeInterval] = [0.2, 0.17, 0.1, 0.2, pause]
        let duration: TimeInterval = steps.reduce(0.0, +)
        let amplitude: CGFloat = style.rawValue

        let animation = CAKeyframeAnimation(keyPath: "transform.scale")

        var offset: TimeInterval = 0.0
        animation.keyTimes = steps.map { (step: Double) in
            defer {
                offset += step
            }
            return .init(value: (offset + step) / duration)
        }

        animation.values = [1.0, 1 + amplitude, 1 - amplitude, 1 + amplitude * 0.75, 1.0]
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        if repeats {
            animation.repeatCount = .infinity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.layer.add(animation, forKey: animationKey)
        }
    }

    func removeBounceAnimation() {
        let animationKey = "bounce"
        layer.removeAnimation(forKey: animationKey)
    }

    // MARK: - Spring Animation

    static func defaultSpringAnimation(_ animations: @escaping (() -> Void)) {
        defaultSpringAnimation(duration: 0.35, animations: animations)
    }

    static func defaultSpringAnimation(duration: TimeInterval = 0.35,
                                       delay: TimeInterval = 0.0,
                                       options: UIView.AnimationOptions = [],
                                       animations: @escaping (() -> Void),
                                       completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: 0.95,
                       initialSpringVelocity: 0.5,
                       options: options,
                       animations: {
            animations()
        }, completion: completion)
    }

    func layout() {
        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: - Animation Parameters

    class func animate(with parameters: BaseAnimationParameters, 
                       animations: @escaping () -> Void,
                       completion: ((Bool) -> Void)? = nil) {
        animate(withDuration: parameters.duration,
                delay: parameters.delay,
                options: parameters.options,
                animations: animations,
                completion: completion)
    }

    class func animate(with parameters: SpringAnimationParameters, 
                       animations: @escaping () -> Void,
                       completion: ((Bool) -> Void)? = nil) {
        animate(withDuration: parameters.duration,
                delay: parameters.delay,
                usingSpringWithDamping: parameters.dampingRatio,
                initialSpringVelocity: parameters.velocity,
                options: parameters.options,
                animations: animations,
                completion: completion)
    }

    // MARK: - setHidden

    func setHidden(_ isHidden: Bool, animated: Bool) {
        guard self.isHidden != isHidden else {
            return
        }
        
        layer.removeAllAnimations()
        guard animated else {
            self.isHidden = isHidden
            return
        }

        let sourceAlpha = alpha
        if isHidden {
            UIView.defaultSpringAnimation(animations: {
                self.alpha = 0
            }, completion: { (isFinished: Bool) in
                guard isFinished else {
                    return
                }

                self.isHidden = isHidden
                self.alpha = sourceAlpha
            })
        }
        else {
            alpha = 0
            self.isHidden = false
            UIView.defaultSpringAnimation {
                self.alpha = sourceAlpha
            }
        }
    }
}
