//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension UIViewController {

    var isVisible: Bool {
        return isViewLoaded && view.window != nil
    }

    var focusedViewController: UIViewController {
        if let presentedViewController = presentedViewController {
            return presentedViewController.focusedViewController
        }
        if let navigationController = self as? UINavigationController,
           let topViewController = navigationController.topViewController {
            let controller = topViewController.presentedViewController ?? topViewController
            return controller.focusedViewController
        }
        return self
    }

    func add(child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
    }

    func add(child: UIViewController, to containerView: UIView, insets: UIEdgeInsets = .zero) {
        addChild(child)
        containerView.addSubview(child.view)
        child.view.bindMarginsToSuperview(insets: insets)
    }
}
