//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit
import AVFoundation
import PhotosUI
import GenericModule

public protocol MediaPickerCoordinatorOutput: AnyObject {
    func mediaPickerCoordinatorDidSelect(_ coordinator: MediaPickerCoordinator, items: [MediaFetchService.Item])
    func mediaPickerCoordinatorDidCancel(_ coordinator: MediaPickerCoordinator)
}

public final class MediaPickerCoordinator: Coordinator<UIViewController> {
    public enum SelectionStyle {
        case basic(Int)
        case ordered(Int)
    }

    public let colorScheme: ColorScheme
    public var selectionStyle: SelectionStyle = .basic(1)
    public var shouldTreatLivePhotosAsVideos: Bool = true
    public var filter: PHPickerFilter?

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
        configuration.preferredAssetRepresentationMode = .current
        if #available(iOS 17.0, *) {
            configuration.disabledCapabilities = [.sensitivityAnalysisIntervention]
        }
        return configuration
    }()
    
    public init(rootViewController: UIViewController, colorScheme: ColorScheme, filter: PHPickerFilter? = nil) {
        self.colorScheme = colorScheme
        self.filter = filter
        super.init(rootViewController: rootViewController)
    }
    
    public func start(completion: (() -> Void)? = nil) {
        retainedSelf = self
        loadingViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(loadingViewController, animated: true)

        pickerConfiguration.filter = filter
        switch selectionStyle {
        case .basic(let count):
            pickerConfiguration.selection = .default
            pickerConfiguration.selectionLimit = count
        case .ordered(let count):
            pickerConfiguration.selection = .ordered
            pickerConfiguration.selectionLimit = count
        }

        let pickerViewController = PHPickerViewController(configuration: pickerConfiguration)
        pickerViewController.delegate = self
        pickerViewController.modalTransitionStyle = .crossDissolve
        pickerViewController.modalPresentationStyle = loadingViewController.modalPresentationStyle
        loadingViewController.present(pickerViewController, animated: true, completion: completion)
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

    public func dismissSheet() {
        if let controller = sheetViewController.presentingViewController {
            controller.dismiss(animated: true)
        }
        else {
            sheetViewController.dismiss()
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension MediaPickerCoordinator: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard results.isEmpty == false else {
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
            self.handle(results)
        }
    }
    
    private func handle(_ results: [PHPickerResult]) {
        mediaFetchService.fetchContents(for: results,
                                        treatingLivePhotosAsVideos: shouldTreatLivePhotosAsVideos,
                                        progress: progressHandler,
                                        success: completionHandler,
                                        failure: errorHandler)
    }

    private func completionHandler(_ items: [MediaFetchService.Item]) {
        sheetContent.state = .progress("Fetching", 1.0)
        sheetViewController.updateContent()
        output?.mediaPickerCoordinatorDidSelect(self, items: items)
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
