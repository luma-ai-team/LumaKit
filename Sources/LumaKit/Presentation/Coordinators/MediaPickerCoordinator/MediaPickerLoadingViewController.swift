//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

class MediaPickerLoadingViewController: UIViewController {

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .label
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading"
        label.textColor = .label
        return label
    }()

    private lazy var visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        return view
    }()

    private let colorScheme: ColorScheme
    
    init(colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(visualEffectView)
        view.addSubview(activityIndicatorView)
        view.addSubview(titleLabel)

        activityIndicatorView.startAnimating()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        visualEffectView.frame = view.bounds

        activityIndicatorView.sizeToFit()
        activityIndicatorView.center = view.bounds.center

        titleLabel.sizeToFit()
        titleLabel.center = .init(x: view.bounds.midX,
                                  y: activityIndicatorView.frame.maxY + titleLabel.bounds.midY + 20.0)
    }
}

