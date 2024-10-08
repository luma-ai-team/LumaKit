//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension UIEdgeInsets {
    
    var horizontalSum: CGFloat {
        return left + right
    }

    var verticalSum: CGFloat {
        return top + bottom
    }

    init(value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }

    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}
