//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class BounceGestureRecognizer: UILongPressGestureRecognizer {
    var handler: (() -> Void)?

    public init(handler: (() -> Void)? = nil) {
        self.handler = handler
        super.init(target: nil, action: nil)
        minimumPressDuration = 0.0
        cancelsTouchesInView = false
        addTarget(self, action: #selector(viewPressed))
    }

    // MARK: - Actions

    @objc private func viewPressed() {
        if state == .began {
            animateView(isPressed: true)
        }
        else if isFinished {
            animateView(isPressed: false)
            handler?()
        }
    }

    private func animateView(isPressed: Bool) {
        guard let view = view else {
            return
        }

        let bounceScale: CGFloat = 0.9
        let alphaValue: CGFloat = 0.3
        let duration: TimeInterval = 0.1

        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = isPressed ? [1.0, bounceScale] : [bounceScale, 1.0]
        scaleAnimation.keyTimes = [0, 1]
        scaleAnimation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut)]
        scaleAnimation.duration = duration
        scaleAnimation.isRemovedOnCompletion = isPressed == false
        scaleAnimation.fillMode = .forwards

        // Alpha animation
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = isPressed ? 1.0 : alphaValue
        alphaAnimation.toValue = isPressed ? alphaValue : 1.0
        alphaAnimation.duration = duration
        alphaAnimation.isRemovedOnCompletion = isPressed == false
        alphaAnimation.fillMode = .forwards

        view.layer.add(scaleAnimation, forKey: "bounceGestureScale")
        view.layer.add(alphaAnimation, forKey: "bounceGestureOpacity")
    }
}
