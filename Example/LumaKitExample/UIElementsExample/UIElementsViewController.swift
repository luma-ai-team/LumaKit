//
//  UIElementsViewController.swift
//  LumaKitExample
//
//  Created by Anton Kormakov on 22.02.2024.
//

import UIKit
import LumaKit

final class UIElementsViewController: UIViewController {

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()

    private lazy var containerView: UIView = .init()

    // MARK: - Elements

    private lazy var bounceButton: BounceButton = {
        let button = BounceButton()
        button.setTitle("BounceButton", for: .normal)
        button.backgroundColor = .lightGray
        button.bounds.size.height = 60.0
        return button
    }()

    private lazy var bounceLabel: UILabel = {
        let label = UILabel()
        label.font = .compatibleSystemFont(ofSize: 14.0, weight: .semibold, width: .compressed)
        label.text = "UILabel w/ BounceGestureRecognizer"
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(BounceGestureRecognizer(handler: {
            print("Bounced")
        }))
        label.bounds.size.height = 60.0
        return label
    }()

    private lazy var gradientLabel: GradientLabel = {
        let view = GradientLabel()
        view.text = "Gradient Label"
        view.textAlignment = .center
        view.gradient = .horizontal(colors: [.red, .green])
        view.bounds.size.height = 40.0
        return view
    }()

    private lazy var gradientView: GradientView = {
        let view = GradientView(gradient: .horizontal(colors: [.purple, .blue]))
        view.bounds.size.height = 40.0
        return view
    }()

    private lazy var animatedGradientView: AnimatedGradientView = {
        let gradient = Gradient.horizontal(colors: [.purple, .blue, .red, .black])
        let view = AnimatedGradientView(gradient: gradient)
        view.stepDuration = 1.0
        view.startAnimating()
        view.bounds.size.height = 40.0
        return view
    }()

    private lazy var gradientProgressView: GradientProgressView = {
        let view = GradientProgressView(gradient: .horizontal(colors: [.blue, .yellow]))
        view.setProgress(progress: 0.5, animation: .none)
        view.backgroundColor = .lightGray
        view.bounds.size.height = 16.0
        return view
    }()

    private lazy var gradientButton: GradientButton = {
        let button = GradientButton()
        button.gradient = .diagonalLTR(colors: [.yellow, .red])
        button.setTitle("GradientButton", for: .normal)
        button.bounds.size.height = 60.0
        return button
    }()

    private lazy var shimmerButton: ShimmerButton = {
        let button = ShimmerButton()
        button.gradient = .vertical(colors: [.red, .cyan])
        button.setTitle("ShimmerButton", for: .normal)
        button.shimmerColor = .purple
        button.bounds.size.height = 60.0
        return button
    }()

    private lazy var playerLooper: PlayerLooper = {
        let url = Bundle.main.url(forResource: "video.mov", withExtension: nil) ?? .root
        return .init(url: url)
    }()

    private lazy var playerView: PlayerView = {
        let view = PlayerView()
        view.player = playerLooper.player
        view.bounds.size.height = 120.0
        return view
    }()

    private lazy var animationSequenceViews: [UIView] = {
        let colors: [UIColor] = [.red, .green, .blue, .black]
        return colors.map { (color: UIColor) in
            let view = UIView()
            view.backgroundColor = color
            return view
        }
    }()

    private lazy var animationSequenceContainerView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        for subview in animationSequenceViews {
            view.addArrangedSubview(subview)
        }
        view.bounds.size.height = 80.0
        return view
    }()

    private lazy var passiveContainerViewLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "PassiveContainerView allows its subviews to catch touch events, " +
                     "but ignores touches to itself, bypassing them to superview."
        return label
    }()

    private lazy var passiveContainerView: PassiveContainerView = {
        let view = PassiveContainerView()
        view.backgroundColor = .black.withAlphaComponent(0.05)
        view.addSubview(passiveContainerViewLabel)
        passiveContainerViewLabel.bindMarginsToSuperview()

        view.bounds.size.height = 120.0
        return view
    }()

    private lazy var sheetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Sheet", for: .normal)
        button.addTarget(self, action: #selector(sheetButtonPressed), for: .touchUpInside)
        button.bounds.size.height = 44.0
        return button
    }()

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "UIElements"
        view.backgroundColor = .white

        view.addSubview(scrollView)
        scrollView.addSubview(containerView)

        containerView.addSubview(sheetButton)
        containerView.addSubview(bounceButton)
        containerView.addSubview(bounceLabel)
        containerView.addSubview(gradientLabel)
        containerView.addSubview(gradientView)
        containerView.addSubview(animatedGradientView)
        containerView.addSubview(gradientProgressView)
        containerView.addSubview(gradientButton)
        containerView.addSubview(shimmerButton)
        containerView.addSubview(playerView)
        containerView.addSubview(animationSequenceContainerView)
        containerView.addSubview(passiveContainerView)

        containerView.subviews.animateCascadeSpring(fromAlpha: 0.0, toAlpha: 1.0, completion: {
            print("Animation done")
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareElements()
    }

    private func prepareElements() {
        playerLooper.player.play()
        setupProgressViewAnimation()
        setupAnimationSequence()
    }

    private func setupProgressViewAnimation() {
        gradientProgressView.setProgress(progress: 0.0, animation: .none)
        gradientProgressView.setProgress(progress: 1.0, animation: .spring(duration: 10.0))
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.setupProgressViewAnimation()
        }
    }

    private func setupAnimationSequence() {
        for view in animationSequenceViews {
            view.alpha = 0.0
        }

        let sequence = AnimationSequence()
        sequence.animate(withDuration: 0.5, animations: {
            self.animationSequenceViews[0].alpha = 1.0
        })
        sequence.animate(withDuration: 0.5, animations: {
            self.animationSequenceViews[1].alpha = 1.0
        })
        sequence.wait(forDuration: 1.0)
        sequence.animate(withDuration: 0.5, animations: {
            self.animationSequenceViews[2].alpha = 1.0
        })
        sequence.animate(withDuration: 0.5, animations: {
            self.animationSequenceViews[3].alpha = 1.0
        })
        sequence.sync(setupAnimationSequence)
        sequence.start()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds
        containerView.frame = scrollView.bounds.inset(by: scrollView.safeAreaInsets)

        var offset: CGFloat = 16.0
        for element in containerView.subviews {
            element.frame.origin.x = 16.0
            element.frame.origin.y = offset
            element.frame.size.width = containerView.bounds.width - 32.0

            offset = element.frame.maxY + 8.0
        }

        containerView.frame.size.height = offset
        scrollView.contentSize = containerView.bounds.size
    }

    // MARK: - Actions

    @objc private func sheetButtonPressed() {
        let content = ProgressSheetContent(colorScheme: .init())
        content.state = .progress("Doing stuff", 0.5)
        
        let controller = SheetViewController(content: content)
        present(controller, animated: true)
    }
}
