//
//  MediaPickerSourceButton.swift
//  LumaKit
//
//  Created by Anton Kormakov on 20.01.2025.
//

import UIKit

public final class MediaPickerSourceButton: BounceButton {
    public let source: MediaPickerCoordinator.Source

    public override var materialStyle: MaterialStyle {
        didSet {
            layer.borderWidth = materialStyle.isDefault ? 1.0 : 0.0
        }
    }

    public init(source: MediaPickerCoordinator.Source) {
        self.source = source
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        applyCornerRadius(value: 14.0)
        titleLabel?.font = .roundedSystemFont(ofSize: 13.0, weight: .regular)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        guard let titleLabel = titleLabel,
              let imageView = imageView else {
            return
        }

        titleLabel.center = .init(x: bounds.midX, y: bounds.midY + titleLabel.bounds.midY + 2.0)
        imageView.center = .init(x: bounds.midX, y: bounds.midY - imageView.bounds.midY - 2.0)
    }
}
