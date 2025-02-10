//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit
import AVFoundation
import PhotosUI
import GenericModule

@MainActor
public protocol MediaPickerCoordinatorOutput: AnyObject {
    func mediaPickerCoordinatorDidSelect(_ coordinator: MediaPickerCoordinator, items: [MediaFetchService.Item])
    func mediaPickerCoordinatorDidCancel(_ coordinator: MediaPickerCoordinator)
}

public final class MediaPickerCoordinator: Coordinator<UIViewController> {
    public enum SelectionStyle {
        case basic(Int)
        case ordered(Int)
    }

    public enum Source {
        case camera
        case library
        case files
    }

    public let colorScheme: ColorScheme
    public var selectionStyle: SelectionStyle = .basic(1)
    public var shouldTreatLivePhotosAsVideos: Bool = true
    public var filter: PHPickerFilter?

    public var sources: [Source] = [.library]
    public var shouldApplyFrontCameraFlipWorkaround: Bool = true
    public private(set) var activeSource: Source?
    public var sourcePickerBottomView: UIView?

    public weak var output: MediaPickerCoordinatorOutput?

    private lazy var mediaFetchService: MediaFetchService = .init()

    private lazy var loadingViewController: MediaPickerLoadingViewController = {
        let controller = MediaPickerLoadingViewController(colorScheme: colorScheme)
        return controller
    }()

    private lazy var sheetContent: ProgressSheetContent = .init(colorScheme: colorScheme)
    private lazy var sheetViewController: SheetViewController = makeSheetViewController()
    private var sheetDismissHandler: (() -> Void)?
    private var sourcePickerViewController: SheetViewController?

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

        if sources.first == sources.last {
            let source = sources.first ?? .library
            start(source: source, completion: completion)
        }
        else {
            let content = MediaPickerSourceViewController(sources: sources)
            content.userContent = sourcePickerBottomView
            content.colorScheme = colorScheme
            content.delegate = self

            let controller = SheetViewController(content: content)
            controller.dismissHandler = { [weak self] in
                self?.retainedSelf = nil
            }
            rootViewController.present(controller, animated: true)
            sourcePickerViewController = controller
            completion?()
        }
    }

    private func start(source: Source, animated: Bool = true, completion: (() -> Void)? = nil) {
        activeSource = source
        switch source {
        case .library:
            startLibrary(animated: animated, completion: completion)
        case .camera:
            startCamera(animated: animated, completion: completion)
        case .files:
            startFilePicker(animated: animated, completion: completion)
        }
    }

    private func startLibrary(animated: Bool, completion: (() -> Void)? = nil) {
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
        pickerViewController.modalPresentationStyle = .fullScreen

        loadingViewController.modalPresentationStyle = .fullScreen
        topViewController.present(loadingViewController, animated: true) {
            self.loadingViewController.present(pickerViewController, animated: animated, completion: completion)
        }
    }

    private func startCamera(animated: Bool, completion: (() -> Void)? = nil) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authorizationStatus {
        case .notDetermined:
            Task {
                let isGranted = await AVCaptureDevice.requestAccess(for: .video)
                if isGranted {
                    startCamera(animated: true)
                }
                else {
                    showCameraPermissionsDeniedAlert()
                }
            }
            return
        case .denied:
            return showCameraPermissionsDeniedAlert()
        default:
            break
        }

        let controller = CameraViewController()
        controller.shouldApplyFrontCameraFlipWorkaround = shouldApplyFrontCameraFlipWorkaround
        controller.sourceType = .camera
        controller.delegate = self
        topViewController.present(controller, animated: animated, completion: completion)
    }

    private func startFilePicker(animated: Bool, completion: (() -> Void)? = nil) {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.image])
        controller.delegate = self
        topViewController.present(controller, animated: animated, completion: completion)
    }

    private func showCameraPermissionsDeniedAlert() {
        let controller = UIAlertController(title: "Camera Access Denied",
                                           message: "Please enable camera access in settings to use this feature.",
                                           preferredStyle: .alert)

        let dismissAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        controller.addAction(dismissAction)

        let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            UIApplication.shared.open(url)
        }
        controller.addAction(settingsAction)

        topViewController.present(controller, animated: true)
    }

    private func makeSheetViewController() -> SheetViewController {
        sheetContent = .init(colorScheme: colorScheme)
        sheetContent.state = .progress("Fetching", 0.0)
        let controller = SheetViewController(content: sheetContent)
        controller.dismissHandler = { [weak self] in
            self?.sheetDismissHandler?()
            self?.sheetDismissHandler = nil

            self?.mediaFetchService.cancel()
        }
        return controller
    }

    private func presentSheetIfNeeded() {
        guard sheetViewController.isVisible == false else {
            return
        }

        topViewController.present(sheetViewController, animated: true)
    }

    public func dismiss() {
        retainedSelf = nil
        if rootViewController.presentedViewController === loadingViewController {
            rootViewController.dismiss(animated: true)
        }
        else if rootViewController.presentedViewController is UIImagePickerController {
            rootViewController.dismiss(animated: true)
        }
        else if let sourcePickerViewController = self.sourcePickerViewController,
                rootViewController.presentedViewController == sourcePickerViewController {
            rootViewController.dismiss(animated: true)
        }
    }

    public func show(title: String, progress: Double, dismissHandler: (() -> Void)? = nil) {
        self.sheetDismissHandler = dismissHandler
        presentSheetIfNeeded()

        sheetContent.state = .progress(title, progress)
        sheetViewController.updateContent()
    }

    public func show(_ error: Error, dismissHandler: (() -> Void)? = nil) {
        self.sheetDismissHandler = dismissHandler
        errorHandler(error)
    }

    public func show(image: UIImage?, title: String, subtitle: String, dismissHandler: (() -> Void)? = nil) {
        self.sheetDismissHandler = dismissHandler
        presentSheetIfNeeded()

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
        picker.present(sheetViewController, animated: true, completion: {
            self.handle(results)
        })
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
        presentSheetIfNeeded()

        sheetContent.state = .failure(error)
        sheetViewController.updateContent()
    }
}

// MARK: - UIImagePickerControllerDelegate

extension MediaPickerCoordinator: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard var image = (info[.editedImage] ?? info[.originalImage]) as? UIImage else {
            output?.mediaPickerCoordinatorDidCancel(self)
            return dismiss()
        }

        if shouldApplyFrontCameraFlipWorkaround,
           picker.cameraDevice == .front,
           let flippedImage = image.flipHorizontally() {
            image = flippedImage
        }

        output?.mediaPickerCoordinatorDidSelect(self, items: [.image(image)])
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        output?.mediaPickerCoordinatorDidCancel(self)
        return dismiss()
    }
}

// MARK: - MediaPickerSourceViewDelegate

extension MediaPickerCoordinator: MediaPickerSourceViewDelegate {
    public func mediaPickerSourceViewDidRequest(_ sender: MediaPickerSourceViewController, source: Source) {
        start(source: source)
    }
}

extension MediaPickerCoordinator: UIDocumentPickerDelegate {
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        output?.mediaPickerCoordinatorDidCancel(self)
        return dismiss()
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let images: [UIImage] = urls.compactMap { (url: URL) in
            return UIImage(contentsOfFile: url.path)
        }
        output?.mediaPickerCoordinatorDidSelect(self, items: images.map { (image: UIImage) in
            return .image(image)
        })
    }
}
