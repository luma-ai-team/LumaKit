//
//  CameraRollActivity.swift
//  AIMusic
//
//  Created by Anton Kormakov on 27.09.2024.
//

import UIKit
import Photos

public class CameraRollPermissionsActivity: UIActivity {
    public let title: String

    public override var activityTitle: String? {
        return title
    }

    public override var activityImage: UIImage? {
        return UIImage(systemName: "square.and.arrow.down",
                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
    }

    public override var activityType: UIActivity.ActivityType? {
        return .init("com.luma.ai.cameraroll")
    }

    public override var activityViewController: UIViewController? {
        let controller = UIAlertController(title: "Permission Denied",
                                           message: "Please allow photo library access to save media files.",
                                           preferredStyle: .alert)

        controller.addAction(.init(title: "Open Settings", style: .default, handler: { _ in
            guard let appSettings = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            self.activityDidFinish(true)
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }))

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.activityDidFinish(false)
        }))
        return controller
    }

    public init(title: String) {
        self.title = title
        super.init()
    }

    public override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .denied, .restricted:
            return true
        default:
            return false
        }
    }
}
