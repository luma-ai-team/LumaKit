//
//  PermissionsErrorView.swift
//  LumaKit
//
//  Created by Anton K on 10.03.2025.
//

import UIKit
import LumaKit
import GenericModule

protocol PermissionsErrorViewDelegate: AnyObject {
    func permissionsErrorViewDidRequestSettings(_ sender: PermissionsErrorView)
}

final class PermissionsErrorView: UIView, NibBackedView, SheetContent {
    static var nib: ViewNib {
        return .init(name: "PermissionsErrorView", bundle: .module)
    }

    weak var delegate: PermissionsErrorViewDelegate?

    @IBOutlet weak var actionButton: ShimmerButton!
    @IBOutlet weak var titleLabel: UILabel!

    var colorScheme: ColorScheme = .init() {
        didSet {
            updateColorScheme()
        }
    }

    var isModal: Bool {
        return false
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

        actionButton.applyCornerRadius(value: 14.0)
    }

    private func updateColorScheme() {
        actionButton.setTitleColor(colorScheme.foreground.primary, for: .normal)
        actionButton.gradient = .solid(color: colorScheme.genericAction.active)
        titleLabel.textColor = colorScheme.foreground.primary
    }

    // MARK: - Actions

    @IBAction func actionButtonPressed(_ sender: Any) {
        delegate?.permissionsErrorViewDidRequestSettings(self)
    }
}
