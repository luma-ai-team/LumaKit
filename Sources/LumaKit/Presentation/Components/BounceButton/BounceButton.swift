//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class BounceButton: UIButton {

    open var materialStyle: MaterialStyle = .default {
        didSet {
            materialBorderView.materialStyle = materialStyle
        }
    }

    private lazy var bounceGestureRecognizer: BounceGestureRecognizer = {
        let recognizer = BounceGestureRecognizer()
        recognizer.delegate = self
        return recognizer
    }()

    private lazy var materialBorderView: MaterialBorderView = {
        let view = MaterialBorderView()
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
        addSubview(materialBorderView)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        materialBorderView.frame = bounds
        materialBorderView.layer.cornerRadius = layer.cornerRadius
        materialBorderView.setNeedsLayout()
        bringSubviewToFront(materialBorderView)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BounceButton: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, 
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
