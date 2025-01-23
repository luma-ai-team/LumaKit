//
//  CameraViewController.swift
//  LumaKit
//
//  Created by Anton Kormakov on 23.01.2025.
//

import UIKit

final class CameraViewController: UIImagePickerController {
    var shouldApplyFrontCameraFlipWorkaround: Bool = true
    private var displayLink: CADisplayLink?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        displayLink = CADisplayLink(target: self, selector: #selector(updatePreviewImageView))
        displayLink?.add(to: .main, forMode: .common)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updatePreviewImageView() {
        guard shouldApplyFrontCameraFlipWorkaround,
              cameraDevice == .front else {
            return
        }

        if let previewImageView = fetchPreviewImageView(in: view) {
            previewImageView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
    }

    private func fetchPreviewImageView(in view: UIView) -> UIView? {
        let matchingClassNames = ["PLImageView"]

        let className = String(describing: type(of: view))
        if matchingClassNames.contains(className) {
            return view
        }

        for subview in view.subviews {
            guard let view = fetchPreviewImageView(in: subview) else {
                continue
            }

            return view
        }

        return nil
    }
}
