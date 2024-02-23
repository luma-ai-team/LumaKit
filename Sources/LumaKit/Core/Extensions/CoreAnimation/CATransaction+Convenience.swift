//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension CATransaction {

    static func execute(_ handler: (CATransaction.Type) -> Void, completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        handler(CATransaction.self)
        CATransaction.commit()
    }
}
