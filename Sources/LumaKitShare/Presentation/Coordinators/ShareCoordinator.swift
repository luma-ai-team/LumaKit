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

public final class ShareCoordinator: ModalCoordinator<ShareModule, SharePresenter> {
    enum ShareCoordinatorError: Error {
        case cancelled
    }

    private var colorScheme: ColorScheme = .init()

    private lazy var context: ShareContext = .init(rootViewController: rootViewController)
    private var contentCache: LazyCollection<String, [ShareContent]> = .init()

    @discardableResult
    public func start(with state: ShareState) -> ShareModule {
        colorScheme = state.colorScheme
        return super.start(with: state, dependencies: [])
    }

    private func show(_ error: Error) {
        let controller = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        controller.addAction(.init(title: "Ok", style: .default))
        topViewController.present(controller, animated: true)
    }
}

// MARK: - ShareModuleOutput

extension ShareCoordinator: ShareModuleOutput {
    public func shareModuleDidRequestAppReview(_ input: ShareModuleInput) {
        guard let scene: UIWindowScene = UIApplication.shared.connectedScenes.firstAs() else {
            return
        }

        if let identifier = input.state.applicationIdentifier,
           let url = URL.appStoreURL(withIdentifier: identifier) {
            UIApplication.shared.open(url)
        }
        else {
            SKStoreReviewController.requestReview(in: scene)
        }

    }

    public func shareModuleDidRequestAppFeedback(_ input: ShareModuleInput) {
        let module = FeedbackModule(state: .init(colorScheme: colorScheme), dependencies: [], output: self)
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
        }
        catch {
            self.show(error)
        }
    }
}

// MARK: - FeedbackModuleOutput

extension ShareCoordinator: FeedbackModuleOutput {
    func feedbackModuleDidRequestSend(_ input: FeedbackModuleInput, feedback: String) async {
        await moduleInput?.state.feedbackHandler?(feedback)
        topViewController.dismiss(animated: true)
    }
}
