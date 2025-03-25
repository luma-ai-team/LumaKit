//
//  RateAppView.swift
//  LumaKit
//
//  Created by Anton K on 04.03.2025.
//

import UIKit
import LumaKit
import GenericModule

@MainActor
protocol RateAppViewDelegate: AnyObject {
    func rateAppDidSelect(_ sender: RateAppView, rating: Int)
}

public final class RateAppView: UIView, NibBackedView {
    public static var nib: ViewNib {
        return .init(name: "RateAppView", bundle: .module)
    }

    weak var delegate: RateAppViewDelegate?

    var applicationName: String? {
        didSet {
            let name = applicationName ?? "the App"
            titleLabel.text = "Enjoying \(name)?"
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var starStackView: UIStackView!
    @IBOutlet var starImageViews: [UIImageView]!

    private lazy var pressGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(viewPressed))
        recognizer.minimumPressDuration = 0.0
        return recognizer
    }()

    public var rating: Int? {
        didSet {
            guard rating != oldValue else {
                return
            }

            updateRating()
        }
    }

    public var colorScheme: ColorScheme = .init() {
        didSet {
            updateColorScheme()
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
        starStackView.addGestureRecognizer(pressGestureRecognizer)

        layer.borderWidth = 1.0
        applyCornerRadius(value: 12.0)

        updateColorScheme()
        updateRating()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.performLureAnimation()
        }
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.performLureAnimation()
        }
    }

    private func updateColorScheme() {
        layer.borderColor = colorScheme.genericAction.inactive.cgColor

        titleLabel.textColor = colorScheme.foreground.primary
        subtitleLabel.textColor = colorScheme.foreground.secondary

        for imageView in starImageViews {
            imageView.tintColor = .p3(rgb: 0xFFC52E)
        }
    }

    private func updateRating() {
        let rating = rating ?? 0
        for (index, view) in starImageViews.enumerated() {
            let isSelected = rating > index
            UIView.defaultSpringAnimation(duration: 0.5, delay: CGFloat(index) * 0.075, options: .allowUserInteraction) {
                view.alpha = isSelected ? 1.0 : 0.25
                if isSelected {
                    view.transform = .init(translationX: 0.0, y: -2.0)
                }
            }

            UIView.defaultSpringAnimation(delay: 0.5 + CGFloat(index) * 0.075, options: .allowUserInteraction) {
                view.transform = .identity
            }
        }
    }

    func performLureAnimation() {
        rating = 5
        isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.rating = nil
            self.isUserInteractionEnabled = true
        }
    }

    // MARK: - Actions

    @objc private func viewPressed() {
        let location = pressGestureRecognizer.location(in: starStackView)
        switch pressGestureRecognizer.state {
        case .began, .changed:
            for (index, view) in starImageViews.enumerated() {
                guard view.frame.contains(location) else {
                    continue
                }

                rating = index + 1
                break
            }
        case .ended, .cancelled, .failed:
            delegate?.rateAppDidSelect(self, rating: rating ?? 0)
        default:
            break
        }
    }
}
