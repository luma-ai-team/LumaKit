//
//  AlertContentView.swift
//
//
//  Created by Anton Kormakov on 03.07.2024.
//

import UIKit

@objc public protocol AlertContentHeightProvider {
    @available(iOS 16.0, *)
    var alertHeightResolver: (UITraitCollection) -> CGFloat { get }
}

public protocol AlertContent: AnyObject, AlertContentHeightProvider {
    var view: UIView! { get }
}

extension UIView: AlertContentHeightProvider {
    @available(iOS 16.0, *)
    public var alertHeightResolver: (UITraitCollection) -> CGFloat {
        return { _ -> CGFloat in
            return self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        }
    }
}

extension UIViewController: AlertContent {
    @available(iOS 16.0, *)
    public var alertHeightResolver: (UITraitCollection) -> CGFloat {
        return view.alertHeightResolver
    }
}
