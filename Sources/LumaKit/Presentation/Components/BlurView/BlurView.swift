//
//  BlurView.swift
//  LumaKit
//
//  Created by Anton K on 02.05.2025.
//

import UIKit

public final class BlurView: VisualEffectView {
    public init(style: UIBlurEffect.Style = .regular, opacity: CGFloat = 0.15) {
        super.init(effect: UIBlurEffect(style: style), opacity: opacity)
    }
    
    @MainActor public required init?(coder: NSCoder) {
        super.init(effect: UIBlurEffect(style: .regular), opacity: 0.15)
    }
    
    public var blurOpacity: CGFloat {
        get {
            return effectOpacity
        }
        set {
            effectOpacity = newValue
        }
    }

    public var style: UIBlurEffect.Style = .regular {
        didSet {
            effect = UIBlurEffect(style: style)
        }
    }
}

public class VisualEffectView: UIView {
    public var effect: UIVisualEffect? {
        didSet {
            visualEffectView.effect = effect
            updateAnimator()
        }
    }

    public var effectOpacity: CGFloat = 0.15 {
        didSet {
            animator.fractionComplete = 1.0 - effectOpacity
        }
    }

    private lazy var visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        return view
    }()

    private lazy var animator: UIViewPropertyAnimator = .init(duration: 1.0, curve: .linear, animations: { [weak self] in
        self?.visualEffectView.effect = nil
    })

    public init(effect: UIVisualEffect?, opacity: CGFloat = 0.15) {
        super.init(frame: .zero)
        self.effect = effect
        self.effectOpacity = opacity
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
        if animator.state != .inactive {
            animator.stopAnimation(true)
            animator.finishAnimation(at: .current)
        }
    }

    private func setup() {
        visualEffectView.effect = effect
        addSubview(visualEffectView)
        visualEffectView.bindMarginsToSuperview()
        animator.pausesOnCompletion = true
    }

    private func updateAnimator() {
        guard superview != nil,
              window != nil else {
            return
        }

        animator.pauseAnimation()
        animator.fractionComplete = 1.0 - effectOpacity
    }

    public override func didMoveToSuperview() {
        updateAnimator()
    }

    public override func didMoveToWindow() {
        updateAnimator()
    }
}
