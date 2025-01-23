//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension UIImage {

    var aspect: CGFloat {
        return size.aspect
    }

    func flipHorizontally() -> UIImage? {
        guard let ciImage = CIImage(image: self, preservingOrientation: true) else {
            return nil
        }

        var result = ciImage.transformed(by: .init(scaleX: -1.0, y: 1.0))
        result = result.transformed(by: .init(translationX: -result.extent.minX, y: -result.extent.minY))

        guard let cgImage = CIContext().createCGImage(result, from: result.extent) else {
            return nil
        }

        return .init(cgImage: cgImage)
    }

    func resizeLanczos(to size: CGSize) -> UIImage? {
        guard let ciImage = CIImage(image: self, preservingOrientation: true) else {
            return nil
        }
        
        let result = ciImage.resizeLanczos(to: size)
        guard let cgImage = CIContext().createCGImage(result, from: result.extent) else {
            return nil
        }

        return .init(cgImage: cgImage)
    }

    func displayTransform(in rect: CGRect) -> CGAffineTransform {
        var transform: CGAffineTransform = .identity

        switch imageOrientation {
        case .up:
            return transform
        case .down, .downMirrored:
            transform = transform.translatedBy(x: rect.width, y: rect.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: rect.width, y: 0.0)
            transform = transform.rotated(by: .pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0.0, y: rect.height)
            transform = transform.rotated(by: -.pi / 2.0)
        case .upMirrored:
            break
        @unknown default:
            break
        }

        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: rect.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: rect.height, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        default:
            break
        }

        return transform
    }
}
