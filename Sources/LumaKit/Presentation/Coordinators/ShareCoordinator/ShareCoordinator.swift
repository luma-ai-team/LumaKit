//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import StoreKit
import Lottie
import GenericModule

public protocol ShareCoordinatorOutput: AnyObject {
    func shareCoordinatorDidCancel(_ coordinator: ShareCoordinator)
    func shareCoordinatorDidSave(_ coordinator: ShareCoordinator, assetIdentifier: String)
}

public final class ShareCoordinator: Coordinator<UIViewController> {
    public enum ShareError: LocalizedError {
        case noPermissions

        public var errorDescription: String? {
            switch self {
            case .noPermissions:
                return "Can't Access Photos"
            }
        }
    }

    public let colorScheme: ColorScheme
    public let contentDescription: String
    public let shouldAskForAppReview: Bool
    public weak var output: ShareCoordinatorOutput?

    public var hasSavingPermissions: Bool {
        return PHPhotoLibrary.authorizationStatus(for: .addOnly) == .authorized
    }

    private lazy var progressContent: ProgressSheetContent = .init(colorScheme: colorScheme)
    private lazy var successContent: SharingSuccessSheetContent = {
        let content = SharingSuccessSheetContent(colorScheme: colorScheme,
                                                 title: "\(contentDescription) Saved Sucessfully",
                                                 shouldAskForAppReview: shouldAskForAppReview)
        content.delegate = self
        return content
    }()

    private lazy var sheetViewController: SheetViewController = makeSheetViewController()
    private var retainedSelf: ShareCoordinator?

    public init(rootViewController: UIViewController, 
                colorScheme: ColorScheme,
                contentDescription: String,
                shouldAskForAppReview: Bool = true) {
        self.colorScheme = colorScheme
        self.contentDescription = contentDescription
        self.shouldAskForAppReview = shouldAskForAppReview
        super.init(rootViewController: rootViewController)
    }

    public func start() {
        retainedSelf = self
        sheetViewController = makeSheetViewController()
        rootViewController.present(sheetViewController, animated: true)
        progressHandler(0.0)
    }

    private func makeSheetViewController() -> SheetViewController {
        progressContent = .init(colorScheme: colorScheme)
        let controller = SheetViewController(content: progressContent)
        controller.dismissHandler = { [weak self] in
            guard let self = self else {
                return
            }

            self.output?.shareCoordinatorDidCancel(self)
            self.dismiss()
        }
        return controller
    }

    public func dismiss() {
        retainedSelf = nil
        if rootViewController.presentedViewController === sheetViewController {
            rootViewController.dismiss(animated: true)
        }
    }

    public func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
        else {
            #if os(visionOS)
            #else
            SKStoreReviewController.requestReview()
            #endif
        }
    }

    public func save(_ image: UIImage) {
        performAssetChanges {
            return PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }

    public func save(_ images: [UIImage]) {
        performAssetChanges {
            var request: PHAssetChangeRequest?
            for image in images {
                request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
            return request
        }
    }

    public func save(_ asset: AVURLAsset) {
        performAssetChanges {
            return PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: asset.url)
        }
    }

    public func show(progress: Double) {
        progressHandler(progress)
    }

    public func show(_ error: Error) {
        errorHandler(error)
    }

    public func show(image: UIImage?, title: String, subtitle: String) {
        progressContent.state = .custom(image, title, subtitle)
        sheetViewController.updateContent()
    }

    private func performAssetChanges(_ handler: @escaping () -> PHAssetChangeRequest?) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    self.showPermissionsError()
                }
                return
            }

            var assetIdentifier: String?
            PHPhotoLibrary.shared().performChanges({
                assetIdentifier = handler()?.placeholderForCreatedAsset?.localIdentifier
            }, completionHandler: { (isSaved: Bool, error: Error?) in
                DispatchQueue.main.async {
                    if let assetIdentifier = assetIdentifier {
                        self.output?.shareCoordinatorDidSave(self, assetIdentifier: assetIdentifier)
                    }

                    if isSaved {
                        self.showSaveCompletion()
                    }
                    else if let error = error {
                        self.show(error)
                    }
                }
            })
        }
    }

    private func showSaveCompletion() {
        sheetViewController.update(with: successContent)

        let confettiView = LottieAnimationView()
        confettiView.animation = LottieAnimation.asset("lottie-confetti-anim", bundle: .module)
        confettiView.contentMode = .scaleAspectFill
        confettiView.play()
        sheetViewController.floatingView = confettiView
    }

    private func showPermissionsError() {
        progressContent.state = .action("Can't Access Photos",
                                        "To save photos to your device, we need Photos access.",
                                        "Open settings", { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            UIApplication.shared.open(url)
        })
        sheetViewController.updateContent()
    }

    private func progressHandler(_ progress: Double) {
        progressContent.state = .progress("Saving \(contentDescription)", progress)
        sheetViewController.updateContent()
    }

    private func errorHandler(_ error: Error) {
        progressContent.state = .failure(error)
        sheetViewController.updateContent()
    }
}

// MARK: - SharingSuccessSheetContentDelegate

extension ShareCoordinator: SharingSuccessSheetContentDelegate {
    public func sharingSuccessSheetContentDidRequestAppReview(_ sender: SharingSuccessSheetContent) {
        requestAppReview()
    }
}
