//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

@objc public protocol SheetContentHeightProvider {
    @available(iOS 16.0, *)
    var heightResolver: (UITraitCollection) -> CGFloat { get }
}

public protocol DismissableSheetContent: AnyObject {
    var dismissHandler: (() -> Void)? { get set }
}

public protocol SheetContent: AnyObject, SheetContentHeightProvider {
    var isModal: Bool { get }
    var view: UIView! { get }
}

extension UIView: SheetContentHeightProvider {
    public var view: UIView! {
        return self
    }

    @available(iOS 16.0, *)
    public var heightResolver: (UITraitCollection) -> CGFloat {
        return { _ -> CGFloat in
            return self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        }
    }
}

extension UIViewController: SheetContent {
    public var isModal: Bool {
        return isModalInPresentation
    }

    @available(iOS 16.0, *)
    public var heightResolver: (UITraitCollection) -> CGFloat {
        return view.heightResolver
    }
}
