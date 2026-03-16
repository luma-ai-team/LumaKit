//
//  MaterialBorderView.swift
//  LumaKit
//
//  Created by Anton K on 02.05.2025.
//

import UIKit

public class MaterialBorderLayer: CALayer {

    public override var cornerRadius: CGFloat {
        didSet {
            setNeedsLayout()
        }
    }

    public var materialStyle: MaterialStyle = .default {
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
        switch materialStyle {
        case .default, .system, .systemInteractive:
            shadowRadius = 0.0
            shadowOpacity = 0.0
            shadowColor = UIColor.clear.cgColor
            gradientLayer.colors = []

        case .glass(let tint):
            shadowColor = tint.cgColor
            shadowRadius = 10
            shadowOpacity = 0.1

            gradientLayer.colors = [
                tint.withAlphaComponent(0.6).cgColor,
                UIColor(rgb: 0x54545C).withAlphaComponent(0.6).cgColor
            ]
        case .matte(let tint, let alpha):
            shadowColor = tint.cgColor
            shadowRadius = 10
            shadowOpacity = 0.1

            gradientLayer.colors = [
                tint.withAlphaComponent(alpha).cgColor,
                tint.withAlphaComponent(alpha).cgColor
            ]
        }
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

public final class MaterialBorderView: PassiveContainerView {
    public override class var layerClass: AnyClass {
        return MaterialBorderLayer.self
    }

    public lazy var materialEffectView: UIVisualEffectView = .init()

    @available(*, unavailable)
    public override var tintColor: UIColor! {
        didSet {
            //
        }
    }

    public var materialStyle: MaterialStyle = .default {
        didSet {
            if oldValue.isSystem {
                materialEffectView.removeFromSuperview()
            }

            (layer as? MaterialBorderLayer)?.materialStyle = materialStyle
            setupMaterialViewIfNeeded()
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
        setupMaterialViewIfNeeded()
    }

    private func setupMaterialViewIfNeeded() {
        isUserInteractionEnabled = materialStyle.isInteractive
        guard #available(iOS 26.0, *),
              materialStyle.isSystem else {
            return
        }

        let effect = UIGlassEffect(style: .regular)
        effect.isInteractive = materialStyle.isInteractive
        effect.tintColor = materialStyle.tintColor
        materialEffectView.effect = effect
        insertSubview(materialEffectView, at: 0)
        layoutIfNeeded()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        if #available(iOS 26.0, *),
           materialStyle.isSystem {
            sendSubviewToBack(materialEffectView)
            materialEffectView.frame = bounds
            materialEffectView.applyCornerRadius(value: layer.cornerRadius)
        }
    }
}
