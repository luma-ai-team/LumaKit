//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension UIImage {

    var aspect: CGFloat {
        return size.aspect
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
}
