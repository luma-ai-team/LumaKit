//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class PassiveContainerView: UIView {
    public weak var touchDelegate: UIView?
    public var fallbackHandler: (() -> Void)?

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view === self {
            let delegatePoint = convert(point, to: touchDelegate)
            let result = touchDelegate?.hitTest(delegatePoint, with: event)
            if result == nil {
                fallbackHandler?()
            }
            
            return result
        }

        return view
    }
}
