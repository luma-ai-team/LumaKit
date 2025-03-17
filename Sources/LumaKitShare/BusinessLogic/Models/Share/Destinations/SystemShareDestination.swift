//
//  SystemShareDestination.swift
//  LumaKit
//
//  Created by Anton K on 03.03.2025.
//

import UIKit
import LumaKit

public final class SystemShareDestination: ShareDestination {
    public let identifier: String = "ai.luma.kit.share.system"
    public let title: String
    public let icon: UIImage?
    public var status: ShareStatus = .available

    public var isPhotoLibraryPermissionsHandlingEnabled: Bool = true

    public init(title: String = "More", icon: UIImage? = nil) {
        self.title = title
        self.icon = icon ?? .init(named: "icMore", in: .module, compatibleWith: nil)
    }

    public func canShare(_ content: [ShareContent]) -> Bool {
        return content.isEmpty == false
    }

    public func share(_ content: [ShareContent], in context: ShareContext) async throws {
        let items = content.map(\.any)

        let permissionsActivity: CameraRollPermissionsActivity = .init(title: "")
        let saveFileActivity: SaveFileActivity = .init(rootViewController: context.rootViewController)
        let activities = [permissionsActivity, saveFileActivity]

        let controller = UIActivityViewController(activityItems: items, applicationActivities: activities)
        controller.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
        ]

        if let popoverController = controller.popoverPresentationController {
            popoverController.sourceView = context.sourceView ?? context.rootViewController.view
            popoverController.sourceRect = context.sourceRect ?? .init(center: context.rootViewController.view.bounds.center,
                                                                       size: .init(width: 40.0, height: 40.0))
            popoverController.permittedArrowDirections = []
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            controller.completionWithItemsHandler = { (activity: UIActivity.ActivityType?, isSuccess: Bool, _, error: Error?) in
                if isSuccess {
                    continuation.resume()
                }
                else {
                    continuation.resume(throwing: error ?? ShareDestinationError.cancelled)
                }

                guard let activity = activity,
                      self.isPhotoLibraryPermissionsHandlingEnabled,
                      activity.rawValue == UIActivity.ActivityType.saveToCameraRoll.rawValue else {
                    return
                }

                if permissionsActivity.canPerform(withActivityItems: []) {
                    self.showPermissionDeniedAlert(in: context)
                } else if isSuccess {
                    self.showAlert(title: "Success", message: "Media saved to your photo library", context: context)
                } else {
                    let errorDescription: String = error?.localizedDescription ?? "System Error"
                    self.showAlert(title: "Error", message: "Failed to save media: \(errorDescription)", context: context)
                }
            }

            context.rootViewController.present(controller, animated: true, completion: nil)
        }
    }

    private func showPermissionDeniedAlert(in context: ShareContext) {
        let alert = UIAlertController(title: "Permission Denied",
                                      message: "Please allow photo library access to save media.",
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "Open Settings", style: .default, handler: { _ in
            guard let appSettings = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        context.rootViewController.present(alert, animated: true, completion: nil)
    }

    private func showAlert(title: String, message: String, context: ShareContext) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: nil))
        context.rootViewController.present(alert, animated: true, completion: nil)
    }
}
