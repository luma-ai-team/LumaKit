//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class DismissableSheetContentViewController: UIViewController, DismissableSheetContent {
    let colorScheme: ColorScheme

    public var isDismissButtonVisible: Bool {
        get {
            return dismissButton.isHidden == false
        }
        set {
            dismissButton.isHidden = newValue == false
        }
    }

    public var dismissHandler: (() -> Void)?

    private(set) lazy var dismissButton: UIButton = {
        let button = BounceButton()
        button.backgroundColor = .clear

        var buttonConfiguration: UIButton.Configuration = .plain()
        buttonConfiguration.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        button.configuration = buttonConfiguration

        let colorConfiguration = UIImage.SymbolConfiguration(paletteColors: [colorScheme.foreground.primary,
                                                                             colorScheme.genericAction.inactive])
        let fontConfiguration = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        let symbolConfiguration = fontConfiguration.applying(colorConfiguration)

        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: symbolConfiguration)
        button.setImage(image, for: .normal)

        button.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)

        return button
    }()

    public init(colorScheme: ColorScheme, nibName: String? = nil, bundle: Bundle? = nil) {
        self.colorScheme = colorScheme
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = colorScheme.background.secondary
        view.addSubview(dismissButton)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dismissButton.frame = CGRect(x: view.bounds.width - 48.0, y: 0.0, width: 48.0, height: 48.0)
    }

    open func setDismissButtonVisible(_ isVisible: Bool, animated: Bool = true) {
        dismissButton.setHidden(isVisible == false, animated: animated)
    }

    // MARK: - Actions

    @objc private func dismissButtonPressed() {
        dismissHandler?()
    }
}
