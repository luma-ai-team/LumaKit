//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

public extension CIImage {
    convenience init?(image: UIImage, preservingOrientation: Bool) {
        self.init(image: image, options: [
            .applyOrientationProperty: preservingOrientation,
            .properties: [
                kCGImagePropertyOrientation: CGImagePropertyOrientation(image.imageOrientation).rawValue
            ]
        ])
    }

    func resizeLanczos(to size: CGSize) -> CIImage {
        let filter = CIFilter.lanczosScaleTransform()
        filter.inputImage = self
        filter.scale = Float(size.height / extent.height)
        filter.aspectRatio = Float(size.width / extent.width) / filter.scale
        return filter.outputImage ?? self
    }
}
