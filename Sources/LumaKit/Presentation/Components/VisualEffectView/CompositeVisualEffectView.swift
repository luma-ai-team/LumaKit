//
//  CompositeVisualEffectView.swift
//  LumaKit
//
//  Created by Anton K on 23.03.2026.
//

import UIKit

public class CompositeVisualEffectView: UIView {
    public struct EffectRecord {
        public let effect: UIVisualEffect
        public var opacity: CGFloat

        public init(effect: UIVisualEffect, opacity: CGFloat = 1.0) {
            self.effect = effect
            self.opacity = opacity
        }
    }

    public var effects: [EffectRecord] = [] {
        didSet {
            updateEffectViews()
        }
    }

    private lazy var containerView: UIView = {
        return .init()
    }()

    public init(effects: [EffectRecord]) {
        self.effects = effects
        super.init(frame: .zero)
        updateEffectViews()
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
        //
    }

    private func updateEffectViews() {
        let needsViewRebuild: Bool = containerView.subviews.count != effects.count
        guard needsViewRebuild else {
            for (view, record) in zip(containerView.subviews, effects) {
                (view as? VisualEffectView)?.effect = record.effect
                (view as? VisualEffectView)?.effectOpacity = record.opacity
            }
            return
        }

        for view in containerView.subviews {
            view.removeFromSuperview()
        }

        for record in effects {
            let view = VisualEffectView(effect: record.effect, opacity: record.opacity)
            containerView.addSubview(view)
        }

        layoutIfNeeded()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        for view in containerView.subviews {
            view.frame = containerView.bounds
        }
    }
}
