//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

/// Base class for animation parameters.
open class BaseAnimationParameters {

    /// The values that indicates animation state. Default value is true.
    open var animated: Bool = true

    /// The total duration of the animations, measured in seconds. If you specify a negative value or 0,
    /// the changes are made without animating them. Default value is 0.35.
    open var duration: TimeInterval = 0.35

    /// The amount of time (measured in seconds) to wait before beginning the animations.
    /// Specify a value of 0 to begin the animations immediately. Default value is 0.
    open var delay: TimeInterval = 0

    /// A mask of options indicating how you want to perform the animations.
    open var options: UIView.AnimationOptions = []

    public init() {}
}
