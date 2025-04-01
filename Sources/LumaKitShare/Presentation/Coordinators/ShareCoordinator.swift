//
//  ShareCoordinator.swift
//  LumaKit
//
//  Created by Anton K on 04.03.2025.
//

import UIKit
import LumaKit
import GenericModule
import StoreKit
import Lottie

public final class ShareCoordinator: ModalCoordinator<ShareModule, SharePresenter> {
    enum ShareCoordinatorError: Error {
        case cancelled
    }

    private var colorScheme: ColorScheme = .init()
    private var didCompleteSharing: Bool = false

    private lazy var context: ShareContext = .init(rootViewController: rootViewController)
    private var contentCache: LazyCollection<String, [ShareContent]> = .init()

    @discardableResult
    public func start(with state: ShareState) -> ShareModule {
        colorScheme = state.colorScheme
        return super.start(with: state, dependencies: Services)
    }

    private func show(_ error: Error) {
        let controller = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        controller.addAction(.init(title: "Ok", style: .default))
        topViewController.present(controller, animated: true)
    }

    private func showSharingSuccess() {
        guard didCompleteSharing == false else {
            return
        }

        let confettiView = LottieAnimationView()
        confettiView.animation = .confetti
        confettiView.contentMode = .scaleAspectFill
        confettiView.play()
        (topViewController as? SheetViewController)?.floatingView = confettiView
        didCompleteSharing = true
    }
}

// MARK: - ShareModuleOutput

extension ShareCoordinator: ShareModuleOutput {
    public func shareModuleDidRequestSystemAppReview(_ input: any ShareModuleInput) {
        guard let scene: UIWindowScene = UIApplication.shared.connectedScenes.firstAs() else {
            return
        }

        SKStoreReviewController.requestReview(in: scene)
    }

    public func shareModuleDidRequestAppReview(_ input: ShareModuleInput, rating: Int) {
        if let identifier = input.state.feedbackConfiguration.appStoreIdentifier,
           let url = URL.appStoreURL(withIdentifier: identifier) {
            UIApplication.shared.open(url)
        }
        else {
            shareModuleDidRequestSystemAppReview(input)
        }
    }

    public func shareModuleDidRequestAppFeedback(_ input: ShareModuleInput, rating: Int) {
        let state = FeedbackState(colorScheme: colorScheme, rating: rating)
        let module = FeedbackModule(state: state, dependencies: [], output: self)
        module.viewController.modalPresentationStyle = .overFullScreen
        module.viewController.modalTransitionStyle = .crossDissolve
        topViewController.present(module.viewController, animated: true)
    }

    public func shareModuleDidRequestOpen(_ input: any ShareModuleInput, url: URL) {
        UIApplication.shared.open(url)
    }

    public func shareModuleDidRequestShare(_ input: ShareModuleInput,
                                           content: [ShareContent],
                                           destination: ShareDestination) async {
        context.rootViewController = topViewController
        do {
            try await destination.share(content, in: self.context)
            showSharingSuccess()
        }
        catch {
            switch error {
            case ShareDestinationError.cancelled:
                break
            default:
                self.show(error)
            }
        }
    }
}

// MARK: - FeedbackModuleOutput

extension ShareCoordinator: FeedbackModuleOutput {
    func feedbackModuleDidRequestSend(_ input: FeedbackModuleInput, feedback: String, rating: Int) async {
        await moduleInput?.state.feedbackConfiguration.handler?(feedback, rating)
        topViewController.dismiss(animated: true)
    }
}
