//
//  BlurView.swift
//  LumaKit
//
//  Created by Anton K on 02.05.2025.
//

import UIKit

public final class BlurView: UIView {
    public var style: UIBlurEffect.Style = .regular {
        didSet {
            visualEffectView.effect = makeBlurEffect()
            updateAnimator()
        }
    }

    public var blurOpacity: CGFloat = 0.15 {
        didSet {
            animator.fractionComplete = 1.0 - blurOpacity
        }
    }

    private lazy var visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: makeBlurEffect())
        return view
    }()

    private lazy var animator: UIViewPropertyAnimator = .init(duration: 1.0, curve: .linear, animations: { [weak self] in
        self?.visualEffectView.effect = nil
    })

    private func makeBlurEffect() -> UIVisualEffect {
        return UIBlurEffect(style: style)
    }

    public init(style: UIBlurEffect.Style = .regular, opacity: CGFloat = 0.15) {
        super.init(frame: .zero)
        self.style = style
        self.blurOpacity = opacity
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    deinit {
        animator.stopAnimation(true)
        animator.finishAnimation(at: .current)
    }

    private func setup() {
        addSubview(visualEffectView)
        visualEffectView.bindMarginsToSuperview()

        updateAnimator()
    }

    private func updateAnimator() {
        animator.startAnimation()
        animator.pauseAnimation()
        animator.fractionComplete = 1.0 - blurOpacity
    }

    public override func didMoveToSuperview() {
        updateAnimator()
    }

    public override func didMoveToWindow() {
        updateAnimator()
    }
}
