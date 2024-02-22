//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension UIFont {
    static func roundedSystemFont(ofSize size: CGFloat, weight: Weight) -> UIFont {
        let font: UIFont = .systemFont(ofSize: size, weight: weight)
        guard let descriptor = font.fontDescriptor.withDesign(.rounded) else {
            return font
        }

        return .init(descriptor: descriptor, size: font.pointSize)
    }
}
