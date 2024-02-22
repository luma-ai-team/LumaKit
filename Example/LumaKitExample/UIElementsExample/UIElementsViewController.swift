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
        label.text = "UILabel w/ BounceGestureRecognizer"
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(BounceGestureRecognizer())
        label.bounds.size.height = 60.0
        return label
    }()

    private lazy var gradientView: GradientView = {
        let view = GradientView(gradient: .horizontal(colors: [.purple, .blue]))
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
        
        playerLooper.player.play()
        return view
    }()

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)

        containerView.addSubview(bounceButton)
        containerView.addSubview(bounceLabel)
        containerView.addSubview(gradientView)
        containerView.addSubview(gradientProgressView)
        containerView.addSubview(gradientButton)
        containerView.addSubview(shimmerButton)
        containerView.addSubview(playerView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds
        containerView.frame = scrollView.bounds

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
}
