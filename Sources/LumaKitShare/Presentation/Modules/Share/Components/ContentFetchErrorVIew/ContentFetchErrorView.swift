//
//  ContentFetchErrorView.swift
//  LumaKit
//
//  Created by Anton K on 10.03.2025.
//

import UIKit
import LumaKit
import GenericModule

final class ContentFetchErrorView: UIView, NibBackedView, SheetContent {
    static var nib: ViewNib {
        return .init(name: "ContentFetchErrorView", bundle: .module)
    }

    var colorScheme: ColorScheme = .init() {
        didSet {
            updateColorScheme()
        }
    }

    var isModal: Bool {
        return false
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
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
        titleLabel.textColor = colorScheme.foreground.primary
        subtitleLabel.textColor = colorScheme.foreground.secondary
    }

    func update(with error: Error) {
        subtitleLabel.text = error.localizedDescription
        setNeedsLayout()
    }
}
