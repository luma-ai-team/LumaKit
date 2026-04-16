//
//  MediaPickerSourceButton.swift
//  LumaKit
//
//  Created by Anton Kormakov on 20.01.2025.
//

import UIKit

public final class MediaPickerSourceButton: BounceButton {
    public let source: MediaPickerCoordinator.Source

    public var badge: String? {
        didSet {
            badgeLabel.text = badge
            badgeView.isHidden = badge == nil
            setNeedsLayout()
        }
    }

    public var colorScheme: ColorScheme = .init() {
        didSet {
            backgroundColor = colorScheme.genericAction.active
            tintColor = colorScheme.foreground.primary
            setTitleColor(colorScheme.foreground.primary, for: .normal)
            layer.borderColor = colorScheme.stroke.primary.cgColor

            badgeView.backgroundColor = colorScheme.primaryAction.active
            badgeLabel.textColor = colorScheme.foreground.tertiary
        }
    }

    public override var materialStyle: MaterialStyle {
        didSet {
            layer.borderWidth = materialStyle.isDefault ? 1.0 : 0.0
        }
    }

    private lazy var badgeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private lazy var badgeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .compatibleSystemFont(ofSize: 11.0, weight: .bold, additionalTraits: .traitItalic)
        return label
    }()

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
        titleLabel?.font = .compatibleSystemFont(ofSize: 12.0, weight: .semibold, design: .rounded)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center

        addSubview(badgeView)
        badgeView.addSubview(badgeLabel)
        badgeLabel.bindMarginsToSuperview(insets: .init(top: 2.0, left: 8.0, bottom: -2.0, right: -8.0))
        badgeView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        badgeView.centerYAnchor.constraint(equalTo: topAnchor).isActive = true
        badgeView.applyCornerRadius(value: 8.0)
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
