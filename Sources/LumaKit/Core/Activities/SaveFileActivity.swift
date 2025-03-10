//
//  SaveFileActivity.swift
//  LumaKit
//
//  Created by Anton K on 03.03.2025.
//

import UIKit

public class SaveFileActivity: UIActivity {
    var urls: [URL] = []

    public override var activityTitle: String? {
        return "Save File"
    }

    public override var activityImage: UIImage? {
        return UIImage(systemName: "square.and.arrow.down",
                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
    }

    public override var activityType: UIActivity.ActivityType? {
        return .init("ai.luma.kit.save.file")
    }

    private let rootViewController: UIViewController

    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    public override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        #if targetEnvironment(macCatalyst)
        let items = activityItems.compactMap { (item: Any) in
            return item as? URL
        }
        return items.isEmpty == false
        #endif

        return false
    }

    public override func perform() {
        let controller = UIDocumentPickerViewController(forExporting: urls, asCopy: true)
        controller.shouldShowFileExtensions = true
        controller.delegate = self
        rootViewController.present(controller, animated: true)
    }

    public override func prepare(withActivityItems activityItems: [Any]) {
        urls = activityItems.compactMap { (item: Any) in
            return item as? URL
        }
    }
}

// MARK: - UIDocumentPickerDelegate

extension SaveFileActivity: UIDocumentPickerDelegate {
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        activityDidFinish(false)
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        activityDidFinish(true)
    }
}
