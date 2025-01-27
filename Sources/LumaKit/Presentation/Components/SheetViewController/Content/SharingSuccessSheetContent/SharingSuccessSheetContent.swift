//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit
import Lottie

public protocol SharingSuccessSheetContentDelegate: AnyObject {
    func sharingSuccessSheetContentDidRequestAppReview(_ sender: SharingSuccessSheetContent)
}

public final class SharingSuccessSheetContent: DismissableSheetContentViewController {

    weak var delegate: SharingSuccessSheetContentDelegate?

    public lazy var successImage: UIImage = {
        let colorConfiguration = UIImage.SymbolConfiguration(paletteColors: [colorScheme.background.primary,
                                                                             colorScheme.foreground.primary])
        let fontConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let symbolConfiguration = fontConfiguration.applying(colorConfiguration)
        return UIImage(systemName: "checkmark.circle.fill", withConfiguration: symbolConfiguration) ?? .init()
    }()
    
    @IBOutlet public weak var titleStackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var appReviewView: UIView!
    @IBOutlet weak var reviewContainerView: UIView!
    @IBOutlet weak var reviewTitleLabel: UILabel!
    @IBOutlet weak var reviewSubtitleLabel: UILabel!
    
    @IBOutlet weak var starsView: LottieAnimationView!

    
    
    private lazy var tapGestureRecoginzer: UITapGestureRecognizer = .init(target: self,
                                                                          action: #selector(viewTapped))

    private let shouldAskForAppReview: Bool

    public init(colorScheme: ColorScheme, title: String, shouldAskForAppReview: Bool) {
        self.shouldAskForAppReview = shouldAskForAppReview
        super.init(colorScheme: colorScheme, bundle: .module)
        self.title = title
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.textColor = colorScheme.foreground.primary
        titleLabel.text = title

        subtitleLabel.textColor = colorScheme.foreground.secondary
        imageView.tintColor = colorScheme.genericAction.active

        appReviewView.isHidden = shouldAskForAppReview == false
        reviewTitleLabel.textColor = colorScheme.foreground.primary
        reviewSubtitleLabel.textColor = colorScheme.foreground.secondary

        starsView.animation = LottieAnimation.asset("lottie-stars-anim", bundle: .module)
        starsView.contentMode = .scaleAspectFill
        starsView.loopMode = .loop
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.starsView.play()
        }
        

        reviewContainerView.backgroundColor = colorScheme.background.primary
        reviewContainerView.applyCornerRadius(value: 10.0)
        reviewContainerView.addGestureRecognizer(tapGestureRecoginzer)
    }

    @objc private func viewTapped() {
        delegate?.sharingSuccessSheetContentDidRequestAppReview(self)
    }
}
