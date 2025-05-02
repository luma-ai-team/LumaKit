//
//  UIView+Glass.swift
//  LumaKit
//
//  Created by Anton K on 02.05.2025.
//

import UIKit

public extension UIView {

    @discardableResult
    func addGlassBorder(tint: UIColor, cornerRadius: CGFloat? = nil) -> GlassBorderView {
        let view = GlassBorderView()
        view.tintColor = tint
        view.isUserInteractionEnabled = false
        view.applyCornerRadius(value: layer.cornerRadius)
        view.translatesAutoresizingMaskIntoConstraints = false
        if let cornerRadius = cornerRadius {
            view.applyCornerRadius(value: cornerRadius)
        }
        addSubview(view)

        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        setNeedsLayout()

        return view
    }
}
