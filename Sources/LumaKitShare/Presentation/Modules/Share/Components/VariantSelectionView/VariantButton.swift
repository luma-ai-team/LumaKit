//
//  VariantButton.swift
//  LumaKit
//
//  Created by Anton K on 06.03.2025.
//

import UIKit
import LumaKit

final class VariantButton: UIButton {
    let variant: ShareContentFetchVariant
    var colorScheme: ColorScheme = .init() {
        didSet {
            updateColorScheme()
        }
    }

    init(variant: ShareContentFetchVariant) {
        self.variant = variant
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        layer.borderWidth = 1.0
        applyCornerRadius(value: 14.0)

        titleLabel?.font = .systemFont(ofSize: 13.0, weight: .regular)
        setTitle(variant.title, for: .normal)
        setImage(variant.icon, for: .normal)

        updateColorScheme()
    }

    private func updateColorScheme() {
        backgroundColor = colorScheme.background.secondary
        tintColor = colorScheme.foreground.primary
        setTitleColor(colorScheme.foreground.primary, for: .normal)
        layer.borderColor = colorScheme.genericAction.inactive.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let titleLabel = titleLabel,
              let imageView = imageView else {
            return
        }

        imageView.sizeToFit()
        imageView.center = .init(x: bounds.midX, y: bounds.midY - imageView.bounds.midY)

        titleLabel.sizeToFit()
        titleLabel.center = .init(x: bounds.midX, y: bounds.midY + titleLabel.bounds.midY + 4.0)
    }
}
