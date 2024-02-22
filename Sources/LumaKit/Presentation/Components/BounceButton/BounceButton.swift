//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class BounceButton: UIButton {
    
    private lazy var bounceGestureRecognizer: BounceGestureRecognizer = {
        let recognizer = BounceGestureRecognizer()
        recognizer.delegate = self
        return recognizer
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
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BounceButton: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, 
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
