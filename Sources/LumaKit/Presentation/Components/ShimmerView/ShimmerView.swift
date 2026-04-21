//
//  ShimmerView.swift
//  LumaKit
//
//  Created by Anton K on 20.04.2026.
//

import UIKit

public final class ShimmerView: UIView {
    public var animationDuration: CFTimeInterval = 2.0

    public var shimmerAlpha: CGFloat = 0.1 {
        didSet {
            updateGradientView()
        }
    }

    public override var tintColor: UIColor! {
        didSet {
            updateGradientView()
        }
    }

    private lazy var gradientView: GradientView = {
        let view = GradientView()
        return view
    }()

    private var displayLink: CADisplayLink?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(gradientView)
        gradientView.bindMarginsToSuperview()

        tintColor = .white
        updateGradientView()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()

        if window == nil {
            stopAnimating()
        }
    }

    private func makeDisplayLink() -> CADisplayLink {
        let frameRate: Float = 1.0 / 30.0
        let proxy = DisplayLinkProxy(target: self, selector: #selector(displayLinkFired))
        let displayLink = CADisplayLink(target: proxy, selector: #selector(proxy.handleDisplayLinkTick))
        displayLink.preferredFrameRateRange = .init(minimum: frameRate, maximum: frameRate, preferred: frameRate)
        displayLink.add(to: .current, forMode: .common)
        return displayLink
    }

    private func updateGradientView() {
        gradientView.gradient = .init(startPoint: .init(x: 1.0, y: 0.2),
                                      endPoint: .init(x: 0.0, y: 0.0),
                                      colors: [.clear, tintColor.withAlphaComponent(shimmerAlpha), .clear],
                                      locations: [0.3, 0.5, 0.7])
    }

    public func startAnimating() {
        guard displayLink == nil else {
            return
        }

        gradientView.alpha = 0.0
        UIView.defaultSpringAnimation {
            self.gradientView.alpha = 1.0
        }

        displayLink?.invalidate()
        displayLink = makeDisplayLink()
    }

    public func stopAnimating() {
        guard displayLink != nil else {
            return
        }

        UIView.defaultSpringAnimation(animations: {
            self.gradientView.alpha = 0.0
        }, completion: { _ in
            self.displayLink?.invalidate()
            self.displayLink = nil
        })
    }

    // MARK: - Actions

    @objc private func displayLinkFired() {
        let time = CFAbsoluteTimeGetCurrent()
        let animationProgress = time / animationDuration
        let progressFraction = 1.0 - (2.0 * (animationProgress - floor(animationProgress)) - 0.5)

        gradientView.gradient.locations = [
            progressFraction - 0.5,
            progressFraction,
            progressFraction + 0.5
        ]
        gradientView.layoutIfNeeded()
    }
}
