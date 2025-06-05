//
//  UIView+Responder.swift
//  LumaKit
//
//  Created by Anton K on 05.06.2025.
//

import UIKit

public extension UIView {
    var firstResponder: UIView? {
        guard isFirstResponder == false else {
            return self
        }

        for view in subviews {
            if let responder = view.firstResponder {
                return responder
            }
        }

        return nil
    }
}
