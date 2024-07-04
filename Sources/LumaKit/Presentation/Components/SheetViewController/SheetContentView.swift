//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

@objc public protocol SheetContentHeightProvider {
    @available(iOS 16.0, *)
    var sheetHeightResolver: (UITraitCollection) -> CGFloat { get }
}

public protocol DismissableSheetContent: AnyObject {
    var dismissHandler: (() -> Void)? { get set }
}

public protocol SheetContent: AnyObject, SheetContentHeightProvider {
    var isModal: Bool { get }
    var view: UIView! { get }
}

extension UIView: SheetContentHeightProvider {
    @available(iOS 16.0, *)
    public var sheetHeightResolver: (UITraitCollection) -> CGFloat {
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
    public var sheetHeightResolver: (UITraitCollection) -> CGFloat {
        return view.sheetHeightResolver
    }
}
