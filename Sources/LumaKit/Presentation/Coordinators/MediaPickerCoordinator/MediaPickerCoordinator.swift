//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit
import AVFoundation
import PhotosUI
import GenericModule

public protocol MediaPickerCoordinatorOutput: AnyObject {
    func mediaPickerCoordinatorDidSelect(_ coordinator: MediaPickerCoordinator, image: UIImage)
    func mediaPickerCoordinatorDidSelect(_ coordinator: MediaPickerCoordinator, asset: AVAsset)
    func mediaPickerCoordinatorDidCancel(_ coordinator: MediaPickerCoordinator)
}

public final class MediaPickerCoordinator: Coordinator<UIViewController> {
    public let colorScheme: ColorScheme

    public var shouldTreatLivePhotosAsVideos: Bool = true
    public weak var output: MediaPickerCoordinatorOutput?

    private lazy var mediaFetchService: MediaFetchService = .init()

    private lazy var loadingViewController: MediaPickerLoadingViewController = {
        let controller = MediaPickerLoadingViewController(colorScheme: colorScheme)
        return controller
    }()

    private lazy var sheetContent: ProgressSheetContent = .init(colorScheme: colorScheme)
    private lazy var sheetViewController: SheetViewController = makeSheetViewController()
    private var retainedSelf: MediaPickerCoordinator?

    private lazy var pickerConfiguration: PHPickerConfiguration = {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .current
        if #available(iOS 17.0, *) {
            configuration.disabledCapabilities = [.sensitivityAnalysisIntervention]
        }
        return configuration
    }()
    
    public init(rootViewController: UIViewController, colorScheme: ColorScheme, filter: PHPickerFilter? = nil) {
        self.colorScheme = colorScheme
        super.init(rootViewController: rootViewController)
        pickerConfiguration.filter = filter
    }
    
    public func start() {
        retainedSelf = self
        loadingViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(loadingViewController, animated: true)

        let pickerViewController = PHPickerViewController(configuration: pickerConfiguration)
        pickerViewController.delegate = self
        pickerViewController.modalTransitionStyle = .crossDissolve
        pickerViewController.modalPresentationStyle = loadingViewController.modalPresentationStyle
        loadingViewController.present(pickerViewController, animated: true)
    }

    private func makeSheetViewController() -> SheetViewController {
        sheetContent = .init(colorScheme: colorScheme)
        sheetContent.state = .progress("", 0.0)
        let controller = SheetViewController(content: sheetContent)
        controller.dismissHandler = { [weak self] in
            self?.mediaFetchService.cancel()
        }
        return controller
    }

    public func dismiss() {
        retainedSelf = nil
        if rootViewController.presentedViewController === loadingViewController {
            rootViewController.dismiss(animated: true)
        }
    }

    public func show(title: String, progress: Double) {
        sheetContent.state = .progress(title, progress)
        sheetViewController.updateContent()
    }

    public func show(_ error: Error) {
        errorHandler(error)
    }

    public func show(image: UIImage?, title: String, subtitle: String) {
        sheetContent.state = .custom(image, title, subtitle)
        sheetViewController.updateContent()
    }
}

// MARK: - PHPickerViewControllerDelegate

extension MediaPickerCoordinator: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let result = results.first else {
            output?.mediaPickerCoordinatorDidCancel(self)
            return dismiss()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if #available(iOS 16, *) {
                let identifiers = results.compactMap(\.assetIdentifier)
                picker.deselectAssets(withIdentifiers: identifiers)
            }
        }

        sheetViewController = makeSheetViewController()
        picker.present(sheetViewController, animated: true)
        DispatchQueue.main.async {
            self.handle(result)
        }
    }
    
    private func handle(_ result: PHPickerResult) {
        if mediaFetchService.canLoadLivePhoto(for: result) {
            if shouldTreatLivePhotosAsVideos {
                fetchAsset(for: result)
            }
            else {
                fetchImage(for: result)
            }
        }
        else if mediaFetchService.canLoadImage(for: result) {
            fetchImage(for: result)
        }
        else {
            fetchAsset(for: result)
        }
    }

    private func fetchAsset(for result: PHPickerResult) {
        mediaFetchService.fetchAsset(for: result, progress: progressHandler, success: { [weak self] (asset: AVAsset) in
            guard let self = self else {
                return
            }

            self.handleFetchCompletion()
            self.output?.mediaPickerCoordinatorDidSelect(self, asset: asset)
        }, failure: errorHandler)
    }

    private func fetchImage(for result: PHPickerResult) {
        mediaFetchService.fetchImage(for: result, progress: progressHandler, success: { [weak self] (image: UIImage) in
            guard let self = self else {
                return
            }

            self.handleFetchCompletion()
            self.output?.mediaPickerCoordinatorDidSelect(self, image: image)
        }, failure: errorHandler)
    }

    private func handleFetchCompletion() {
        sheetContent.state = .progress("Fetching", 1.0)
        sheetViewController.updateContent()
    }

    private func progressHandler(_ progress: Double) {
        sheetContent.state = .progress("Fetching", progress)
        sheetViewController.updateContent()
    }

    private func errorHandler(_ error: Error) {
        sheetContent.state = .failure(error)
        sheetViewController.updateContent()
    }
}
