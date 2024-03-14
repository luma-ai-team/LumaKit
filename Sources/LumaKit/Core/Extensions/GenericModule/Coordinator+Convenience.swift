//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit
import GenericModule

public extension Coordinator {
    var topViewController: UIViewController {
        return rootViewController.focusedViewController
    }
}
