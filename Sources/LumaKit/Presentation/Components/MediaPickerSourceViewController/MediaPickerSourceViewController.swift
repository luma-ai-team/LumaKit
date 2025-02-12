//
//  MediaPickerSourceView.swift
//  LumaKit
//
//  Created by Anton Kormakov on 20.01.2025.
//

import UIKit
import GenericModule

@MainActor
public protocol MediaPickerSourceViewDelegate: AnyObject {
    func mediaPickerSourceViewDidRequest(_ sender: MediaPickerSourceViewController, source: MediaPickerCoordinator.Source)
}

public final class MediaPickerSourceViewController: UIViewController, DismissableSheetContent {
    public weak var delegate: MediaPickerSourceViewDelegate?
    public var dismissHandler: (() -> Void)?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceStackView: UIStackView!
    @IBOutlet weak var userContentView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    
    public var colorScheme: ColorScheme = .init() {
        didSet {
            view.backgroundColor = colorScheme.background.secondary
            titleLabel.textColor = colorScheme.foreground.primary
            updateDismissButton()

            for case let button as MediaPickerSourceButton in sourceStackView.arrangedSubviews {
                button.tintColor = colorScheme.foreground.primary
                button.setTitleColor(colorScheme.foreground.primary, for: .normal)
                button.layer.borderColor = colorScheme.genericAction.inactive.cgColor
            }
        }
    }

    public var sources: [MediaPickerCoordinator.Source] {
        didSet {
            updateSourceButtons()
        }
    }

    public var userContent: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let userContent = userContent else {
                return
            }

            loadViewIfNeeded()
            userContentView.addSubview(userContent)
            userContent.bindMarginsToSuperview()
            view.setNeedsLayout()
        }
    }

    private weak var contentView: UIView?

    public required init(sources: [MediaPickerCoordinator.Source]) {
        self.sources = sources
        super.init(nibName: "MediaPickerSourceViewController", bundle: .module)
    }

    public required init?(coder: NSCoder) {
        self.sources = [.camera, .library]
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        updateDismissButton()
        updateSourceButtons()
    }

    private func updateDismissButton() {
        dismissButton.tintColor = colorScheme.genericAction.inactive
        #if targetEnvironment(macCatalyst)
        dismissButton.isHidden = false
        #else
        dismissButton.isHidden = true
        #endif
    }

    private func updateSourceButtons() {
        for view in sourceStackView.arrangedSubviews {
            sourceStackView.removeArrangedSubview(view)
        }

        for source in sources {
            let view = makeButton(for: source)
            sourceStackView.addArrangedSubview(view)
        }
    }

    private func makeButton(for source: MediaPickerCoordinator.Source) -> UIButton {
        let button = MediaPickerSourceButton(source: source)
        button.addTarget(self, action: #selector(sourceButtonPressed), for: .touchUpInside)

        switch source {
        case .library:
            button.setImage(.init(systemName: "photo.on.rectangle.angled"), for: .normal)
            button.setTitle("Photo Album", for: .normal)
        case .camera:
            button.setImage(.init(systemName: "camera"), for: .normal)
            button.setTitle("Take Photo", for: .normal)
        case .files:
            button.setImage(.init(systemName: "folder"), for: .normal)
            button.setTitle("From Files", for: .normal)
        }

        return button
    }

    // MARK: - Actions

    @objc private func sourceButtonPressed(_ sender: MediaPickerSourceButton) {
        delegate?.mediaPickerSourceViewDidRequest(self, source: sender.source)
    }

    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismissHandler?()
    }
}
