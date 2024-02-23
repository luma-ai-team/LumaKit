//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension UIViewController {

    var isVisible: Bool {
        return isViewLoaded && view.window != nil
    }

    func add(child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
    }
}
