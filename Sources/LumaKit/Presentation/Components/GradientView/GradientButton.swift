//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class GradientButton: BounceButton {
    public var gradient: Gradient {
        get {
            return gradientView.gradient
        }
        set {
            gradientView.gradient = newValue
        }
    }

    public var dimmedGradient: Gradient? {
        get {
            return gradientView.dimmedGradient
        }
        set {
            gradientView.dimmedGradient = newValue
        }
    }

    public var automaticallyAdjustsTitleAlpha: Bool = true

    open override var isEnabled: Bool {
        didSet {
            gradientView.isEnabled = isEnabled
            updateTitleAlphaIfNeeded()
        }
    }

    private lazy var gradientView: GradientView = {
        let view = GradientView()
        view.isUserInteractionEnabled = false
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        clipsToBounds = true
        insertSubview(gradientView, at: 0)
    }

    private func updateTitleAlphaIfNeeded() {
        guard automaticallyAdjustsTitleAlpha else {
            return
        }

        let isDimmed = self.isDimmed || (isEnabled == false)
        titleLabel?.alpha = isDimmed ? 0.35 : 1.0
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.frame = bounds
        sendSubviewToBack(gradientView)
    }

    open override func tintColorDidChange() {
        super.tintColorDidChange()
        updateTitleAlphaIfNeeded()
    }

    public func update(with gradientPair: GradientPair) {
        gradient = gradientPair.active
        dimmedGradient = gradientPair.inactive
    }
}
