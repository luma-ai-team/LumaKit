//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension UIGestureRecognizer {

    var isCancelled: Bool {
        return state == .cancelled
    }

    var isFinished: Bool {
        switch state {
        case .cancelled, .ended, .failed:
            return true
        default:
            return false
        }
    }

    var isTracking: Bool {
        switch state {
        case .began, .changed:
            return true
        default:
            return false
        }
    }

    func cancel() {
        let wasEnabled = isEnabled
        isEnabled = false
        isEnabled = wasEnabled
    }
}

