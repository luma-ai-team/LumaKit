//
//  UIView+Glass.swift
//  LumaKit
//
//  Created by Anton K on 02.05.2025.
//

import UIKit

public extension UIView {

    @discardableResult
    func addGlassBorder(tint: UIColor, insets: UIEdgeInsets = .zero, cornerRadius: CGFloat? = nil) -> MaterialBorderView {
        return addMaterialBorder(with: .glass(tint: tint), insets: insets, cornerRadius: cornerRadius)
    }

    @discardableResult
    func addMaterialBorder(with style: MaterialStyle,
                           insets: UIEdgeInsets = .zero,
                           cornerRadius: CGFloat? = nil) -> MaterialBorderView {
        let view = MaterialBorderView()
        view.materialStyle = style
        view.isUserInteractionEnabled = false
        view.applyCornerRadius(value: layer.cornerRadius)
        view.translatesAutoresizingMaskIntoConstraints = false
        if let cornerRadius = cornerRadius {
            view.applyCornerRadius(value: cornerRadius)
        }
        addSubview(view)

        view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom).isActive = true
        setNeedsLayout()

        return view
    }
}
