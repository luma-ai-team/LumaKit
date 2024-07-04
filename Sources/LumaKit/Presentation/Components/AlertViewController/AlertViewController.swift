//
//  ProgressAlertViewController.swift
//
//
//  Created by Anton Kormakov on 03.07.2024.
//

import UIKit

open class AlertViewController: UIViewController {
    public private(set) var content: any AlertContent
    public private(set) var action: UIAction?
    public let colorScheme: ColorScheme

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var actionButton: UIButton!

    public init(content: any AlertContent, colorScheme: ColorScheme, action: UIAction? = nil) {
        self.content = content
        self.action = action
        self.colorScheme = colorScheme
        super.init(nibName: nil, bundle: .module)

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        containerView.layer.cornerRadius = 30.0
        containerView.transform = .init(scaleX: 0.9, y: 0.9)
        stackView.backgroundColor = colorScheme.background.secondary.withAlphaComponent(0.95)

        separatorView.backgroundColor = colorScheme.foreground.primary.withAlphaComponent(0.4)

        actionButton.tintColor = colorScheme.genericAction.active
        actionButton.titleLabel?.font = .compatibleSystemFont(ofSize: 14.0, weight: .medium, design: .rounded)
        actionButton.addGestureRecognizer(BounceGestureRecognizer())

        update(with: content, action: action)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.defaultSpringAnimation {
            self.containerView.transform = .identity
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.defaultSpringAnimation {
            self.containerView.transform = .init(scaleX: 0.9, y: 0.9)
        }
    }

    open func update(with content: any AlertContent, action: UIAction? = nil) {
        if self.content !== content {
            content.view.frame.size.width = self.content.view.frame.size.width
            self.content.view.removeFromSuperview()
        }

        if let oldAction = self.action {
            actionButton.removeAction(oldAction, for: .touchUpInside)
        }

        self.content = content
        self.action = action

        actionView.setHidden(action == nil, animated: false)
        if let action = action {
            actionButton.setTitle(action.title, for: .normal)
            actionButton.addAction(action, for: .touchUpInside)
        }

        contentView.addSubview(content.view)
        content.view.bindMarginsToSuperview()
        content.view.layoutIfNeeded()
    }

    open func updateContent() {
        content.view.layoutIfNeeded()
    }

    // MARK: - Actions

    @IBAction func actionButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
