//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

/// Class for spring animation parameters.
open class SpringAnimationParameters: BaseAnimationParameters {

    /// The damping ratio for the spring animation as it approaches its quiescent state. To smoothly decelerate the animation
    /// without oscillation, use a value of 1. Employ a damping ratio closer to zero to increase oscillation.
    open var dampingRatio: CGFloat = 0.95

    /// The initial spring velocity. For smooth start to the animation, match this value to the view’s velocity
    /// as it was prior to attachment. A value of 1 corresponds to the total animation distance traversed in one second.
    open var velocity: CGFloat = 0.5

    public override init() {}
}
