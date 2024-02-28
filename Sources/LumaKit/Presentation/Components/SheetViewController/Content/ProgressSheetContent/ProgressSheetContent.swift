//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public final class ProgressSheetContent: DismissableSheetContentViewController {

    public enum State {
        case progress(String, Double)
        case failure(Error)
        case success(String)
        case custom(UIImage?, String, String?)
        case action(String, String?, String, (UIAction) -> Void)
    }

    public var state: State {
        didSet {
            updateState()
        }
    }

    public lazy var errorImage: UIImage = {
        let colorConfiguration = UIImage.SymbolConfiguration(paletteColors: [colorScheme.background.primary,
                                                                             colorScheme.foreground.primary])
        let fontConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let symbolConfiguration = fontConfiguration.applying(colorConfiguration)
        return UIImage(systemName: "xmark.circle.fill", withConfiguration: symbolConfiguration) ?? .init()
    }()

    public lazy var successImage: UIImage = {
        let colorConfiguration = UIImage.SymbolConfiguration(paletteColors: [colorScheme.background.primary,
                                                                             colorScheme.foreground.primary])
        let fontConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let symbolConfiguration = fontConfiguration.applying(colorConfiguration)
        return UIImage(systemName: "checkmark.circle.fill", withConfiguration: symbolConfiguration) ?? .init()
    }()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressContainerView: UIView!

    @IBOutlet weak var actionContainerView: UIView!
    @IBOutlet weak var actionButton: BounceButton!
    
    public init(colorScheme: ColorScheme, state: State = .progress(.init(), 0.0)) {
        self.state = state
        super.init(colorScheme: colorScheme, bundle: .module)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        progressView.tintColor = colorScheme.genericAction.active
        progressView.trackTintColor = colorScheme.genericAction.inactive
        progressView.progressTintColor = colorScheme.genericAction.active
        progressView.clipsToBounds = true

        titleLabel.textColor = colorScheme.foreground.primary
        subtitleLabel.textColor = colorScheme.foreground.secondary
        imageView.tintColor = colorScheme.foreground.primary

        actionButton.backgroundColor = colorScheme.genericAction.active
        actionButton.setTitleColor(colorScheme.background.secondary, for: .normal)
        actionButton.titleLabel?.font = .roundedSystemFont(ofSize: 14.0, weight: .semibold)

        updateState()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        progressView.layer.cornerRadius = progressView.bounds.midY
        actionButton.layer.cornerRadius = actionButton.bounds.midY
    }

    private func updateState() {
        loadViewIfNeeded()

        switch state {
        case .progress(let title, let progress):
            progressContainerView.setHidden(false, animated: false)
            actionContainerView.setHidden(true, animated: false)
            progressView.setProgress(Float(progress), animated: true)
            update(title: title)
            isModalInPresentation = true
        case .failure(let error):
            progressContainerView.setHidden(true, animated: false)
            actionContainerView.setHidden(true, animated: false)
            update(with: errorImage, title: "Error", subtitle: error.localizedDescription)
            isModalInPresentation = false
        case .success(let message):
            progressContainerView.setHidden(true, animated: false)
            actionContainerView.setHidden(true, animated: false)
            update(with: successImage, title: message)
            isModalInPresentation = false
        case .custom(let image, let title, let subtitle):
            progressContainerView.setHidden(true, animated: false)
            actionContainerView.setHidden(true, animated: false)
            update(with: image, title: title, subtitle: subtitle)
            isModalInPresentation = false
        case .action(let title, let subtitle, let action, let handler):
            progressContainerView.setHidden(true, animated: false)
            actionContainerView.setHidden(false, animated: true)
            update(with: nil, title: title, subtitle: subtitle)

            actionButton.setTitle(action, for: .normal)
            actionButton.addAction(.init(handler: handler), for: .touchUpInside)
            isModalInPresentation = false
        }

        view.layout()
    }

    private func update(with image: UIImage? = nil, title: String, subtitle: String? = nil) {
        imageView.setHidden(image == nil, animated: false)
        imageView.image = image

        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.setHidden(subtitle == nil, animated: false)
    }
}
