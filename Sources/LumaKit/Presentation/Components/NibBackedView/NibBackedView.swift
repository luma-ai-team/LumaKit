//
//  NibView.swift
//
//
//  Created by Anton Kormakov on 10.09.2024.
//

import UIKit
import GenericModule

public protocol NibBackedView {
    static var nib: ViewNib { get }
}

public extension NibBackedView where Self: UIView {
    static var nib: ViewNib {
        return .init(name: String(describing: Self.self),
                     bundle: Bundle(for: Self.self))
    }

    func loadFromNib() {
        guard let contentView: UIView = Self.nib.instantiate(owner: self) else {
            return
        }

        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
}
