//
//  GlassBorderView.swift
//  LumaKit
//
//  Created by Anton K on 02.05.2025.
//

import UIKit

public class GlassBorderLayer: CALayer {

    public override var cornerRadius: CGFloat {
        didSet {
            setNeedsLayout()
        }
    }

    public var tintColor: UIColor = .white {
        didSet {
            updateTintColor()
        }
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = .init(x: 1.0, y: 0.0)
        layer.endPoint = .init(x: 0.0, y: 1.0)
        return layer
    }()

    private lazy var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 0.5
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        return layer
    }()

    public override init() {
        super.init()
        setup()
    }

    public override init(layer: Any) {
        super.init(layer: layer)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        masksToBounds = true
        addSublayer(gradientLayer)
        gradientLayer.mask = maskLayer

        shadowOffset = .init(width: -5.0, height: 5.0)
        shadowRadius = 10
        shadowOpacity = 0.1

        updateTintColor()
    }

    private func updateTintColor() {
        shadowColor = tintColor.cgColor
        gradientLayer.colors = [
            tintColor.withAlphaComponent(0.6).cgColor,
            UIColor(rgb: 0x54545C).withAlphaComponent(0.6).cgColor
        ]
    }

    public override func action(forKey event: String) -> (any CAAction)? {
        return NSNull()
    }

    public override func layoutSublayers() {
        super.layoutSublayers()
        gradientLayer.frame = bounds

        maskLayer.frame = gradientLayer.bounds.insetBy(dx: 0.5 * maskLayer.lineWidth, dy: 0.5 * maskLayer.lineWidth)
        maskLayer.path = UIBezierPath.continuousRoundedRect(maskLayer.bounds, cornerRadius: cornerRadius).cgPath

        let shadowPath = UIBezierPath.continuousRoundedRect(bounds.insetBy(dx: -0.5 * shadowRadius, dy: -0.5 * shadowRadius),
                                      cornerRadius: cornerRadius)
        shadowPath.append(UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversing())
        self.shadowPath = shadowPath.cgPath
    }
}

public final class GlassBorderView: UIView {
    public override class var layerClass: AnyClass {
        return GlassBorderLayer.self
    }

    public override var tintColor: UIColor! {
        didSet {
            (layer as? GlassBorderLayer)?.tintColor = tintColor
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isUserInteractionEnabled = false
    }
}
