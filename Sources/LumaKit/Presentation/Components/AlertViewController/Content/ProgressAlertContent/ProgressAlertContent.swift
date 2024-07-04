//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class ProgressAlertContent: UIViewController {
    public enum State {
        case progress(String, Double)
        case failure(Error)
        case success(String)
        case custom(UIImage?, String, String?)
    }

    public let colorScheme: ColorScheme

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

    public init(colorScheme: ColorScheme, state: State = .progress(.init(), 0.0)) {
        self.colorScheme = colorScheme
        self.state = state
        super.init(nibName: nil, bundle: .module)
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

        updateState()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        progressView.layer.cornerRadius = progressView.bounds.midY
    }

    private func updateState() {
        loadViewIfNeeded()

        switch state {
        case .progress(let title, let progress):
            progressContainerView.setHidden(false, animated: false)
            progressView.setProgress(Float(progress), animated: true)
            update(title: title)
        case .failure(let error):
            progressContainerView.setHidden(true, animated: false)
            update(with: errorImage, title: "Error", subtitle: error.localizedDescription)
        case .success(let message):
            progressContainerView.setHidden(true, animated: false)
            update(with: successImage, title: message)
        case .custom(let image, let title, let subtitle):
            progressContainerView.setHidden(true, animated: false)
            update(with: image, title: title, subtitle: subtitle)
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
