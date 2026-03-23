//
//  BlurView.swift
//  LumaKit
//
//  Created by Anton K on 23.03.2026.
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
