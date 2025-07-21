//
//  Copyright © 2025 . All rights reserved.
//

import UIKit
import LumaKit
import GenericModule

protocol FeedbackViewOutput: ViewOutput {
    func feedbackEditEventTriggered(feedback: String)
    func submitEventTriggered(feedback: String)
}

final class FeedbackViewController: ViewController<FeedbackViewModel, Any, FeedbackViewOutput> {
    override class var nib: ViewNib {
        return .init(name: "FeedbackViewController", bundle: .module)
    }

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var materialBorderView: MaterialBorderView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var actionButton: BounceButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var contentViewCenterYConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        contentView.alpha = 0.0
        contentView.transform = .init(scaleX: 0.95, y: 0.95)
        contentView.applyCornerRadius(value: 12.0)

        super.viewDidLoad {
            contentView.backgroundColor = viewModel.colorScheme.background.secondary
            titleLabel.textColor = viewModel.colorScheme.foreground.primary
            subtitleLabel.textColor = viewModel.colorScheme.foreground.primary
            placeholderLabel.textColor = viewModel.colorScheme.genericAction.inactive
            activityIndicatorView.color = viewModel.colorScheme.foreground.primary

            textView.delegate = self
            textView.applyCornerRadius(value: 14.0)
            textView.textContainer.lineFragmentPadding = 0.0
            textView.textContainerInset = .init(top: 14.0, left: 12.0, bottom: 12.0, right: 12.0)

            materialBorderView.applyCornerRadius(value: 14.0)
            materialBorderView.materialStyle = viewModel.materialStyle
            
            switch viewModel.materialStyle {
            case .default:
                textView.layer.borderColor = viewModel.colorScheme.genericAction.inactive.cgColor
                textView.layer.borderWidth = 1.0
            default:
                break
            }

            actionButton.applyCornerRadius(value: 14.0)
            actionButton.tintColor = viewModel.colorScheme.foreground.primary
            actionButton.backgroundColor = viewModel.colorScheme.genericAction.active
            actionButton.setTitleColor(viewModel.colorScheme.foreground.primary, for: .normal)
            actionButton.materialStyle = viewModel.materialStyle

            dismissButton.tintColor = viewModel.colorScheme.foreground.primary

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(keyboardFrameWillChange),
                                                   name: UIApplication.keyboardWillChangeFrameNotification,
                                                   object: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated, configurationHandler: {
            UIView.defaultSpringAnimation {
                self.contentView.alpha = 1.0
                self.contentView.transform = .identity
                self.textView.becomeFirstResponder()
            }
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated) {
            contentView.alpha = 0.0
            contentView.transform = .init(scaleX: 0.95, y: 0.95)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func update(with viewUpdate: Update<ViewModel>, animated: Bool) {
        viewUpdate(\.isActionAvailable) { (isActionAvailable: Bool) in
            actionButton.alpha = isActionAvailable ? 1.0 : 0.5
            actionButton.isEnabled = isActionAvailable
            placeholderLabel.isHidden = isActionAvailable
        }

        viewUpdate(\.isPlaceholderHidden) { (isPlaceholderHidden: Bool) in
            placeholderLabel.isHidden = isPlaceholderHidden
        }
    }

    // MARK: - Actions

    @IBAction func actionButtonPressed(_ sender: Any) {
        activityIndicatorView.startAnimating()
        actionButton.setTitle(.init(), for: .normal)
        actionButton.isUserInteractionEnabled = false

        let feedback = textView.text ?? .init()
        output.submitEventTriggered(feedback: feedback)
    }

    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }

    @objc private func keyboardFrameWillChange(_ notification: Notification) {
        guard let rect = notification.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        contentViewCenterYConstraint.constant = 0.5 * (rect.minY - view.safeAreaLayoutGuide.layoutFrame.height)
        view.layoutIfNeeded()
    }
}

// MARK: - UITextViewDelegate

extension FeedbackViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        output.feedbackEditEventTriggered(feedback: textView.text)
    }
}
