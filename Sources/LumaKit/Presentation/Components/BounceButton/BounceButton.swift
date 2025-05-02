//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class BounceButton: UIButton {

    open var materialStyle: MaterialStyle = .default {
        didSet {
            switch materialStyle {
            case .default:
                glassBorderView.isHidden = true
            case .glass(let tint):
                glassBorderView.isHidden = false
                glassBorderView.tintColor = tint
            }
        }
    }

    private lazy var bounceGestureRecognizer: BounceGestureRecognizer = {
        let recognizer = BounceGestureRecognizer()
        recognizer.delegate = self
        return recognizer
    }()

    private lazy var glassBorderView: GlassBorderView = {
        let view = GlassBorderView()
        view.isHidden = true
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        adjustsImageWhenHighlighted = false
        addGestureRecognizer(bounceGestureRecognizer)
        addSubview(glassBorderView)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        glassBorderView.frame = bounds
        glassBorderView.layer.cornerRadius = layer.cornerRadius
        glassBorderView.setNeedsLayout()
        bringSubviewToFront(glassBorderView)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BounceButton: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, 
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
