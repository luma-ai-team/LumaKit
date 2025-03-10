//
//  ContentFetchProgressView.swift
//  LumaKit
//
//  Created by Anton K on 06.03.2025.
//

import UIKit
import LumaKit
import GenericModule

final class ContentFetchProgressView: UIView, NibBackedView, SheetContent {
    static var nib: ViewNib {
        return .init(name: "ContentFetchProgressView", bundle: .module)
    }

    var colorScheme: ColorScheme = .init() {
        didSet {
            updateColorScheme()
        }
    }

    var contentDescription: String = "Content" {
        didSet {
            updateContentDescription()
        }
    }

    var isModal: Bool {
        return true
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var progressView: UIProgressView!

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
        updateContentDescription()
    }

    private func updateColorScheme() {
        titleLabel.textColor = colorScheme.foreground.primary
        subtitleLabel.textColor = colorScheme.foreground.secondary
        progressLabel.textColor = colorScheme.foreground.primary
        progressView.trackTintColor = colorScheme.background.secondary
        progressView.progressTintColor = colorScheme.genericAction.active
    }

    private func updateContentDescription() {
        titleLabel.text = "Preparing Your \(contentDescription.capitalized)"
        subtitleLabel.text = "Do not close the app while preparing \(contentDescription.lowercased())"
        setNeedsLayout()
    }

    func update(progress: Float) {
        progressLabel.text = "\(Int(progress * 100))%"
        progressView.setProgress(progress, animated: true)
        setNeedsLayout()
    }
}
