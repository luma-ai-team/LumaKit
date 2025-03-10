//
//  VariantSelectionView.swift
//  LumaKit
//
//  Created by Anton K on 06.03.2025.
//

import UIKit
import LumaKit
import GenericModule

protocol VariantSelectionViewDelegate: AnyObject {
    func variantSelectionViewDidSelect(_ sender: VariantSelectionView, variant: ShareContentFetchVariant)
}

final class VariantSelectionView: UIView, NibBackedView, SheetContent {
    static var nib: ViewNib {
        return .init(name: "VariantSelectionView", bundle: .module)
    }

    weak var delegate: VariantSelectionViewDelegate?

    var colorScheme: ColorScheme = .init() {
        didSet {
            updateColorScheme()
        }
    }

    var isModal: Bool {
        return false
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    private var buttons: [VariantButton] = [] {
        didSet {
            for view in stackView.arrangedSubviews {
                stackView.removeArrangedSubview(view)
            }

            for button in buttons {
                button.addTarget(self, action: #selector(variantButtonPressed), for: .touchUpInside)
                stackView.addArrangedSubview(button)
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        loadFromNib()
        updateColorScheme()
    }

    private func updateColorScheme() {
        backgroundColor = .clear
        titleLabel.textColor = colorScheme.foreground.primary
    }

    func update(contentDescription: String = "Content", variants: [ShareContentFetchVariant]) {
        titleLabel.text = "Save \(contentDescription) As"
        buttons = variants.map(VariantButton.init)
    }

    // MARK: - Actions

    @objc private func variantButtonPressed(_ sender: VariantButton) {
        delegate?.variantSelectionViewDidSelect(self, variant: sender.variant)
    }
}
