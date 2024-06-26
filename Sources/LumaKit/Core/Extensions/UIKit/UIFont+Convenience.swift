//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension UIFont {
    enum CompatibleWidth {
        case standard
        case condensed
        case expanded
        case compressed

        var systemWidth: Width? {
            if #available(iOS 16.0, *) {
                switch self {
                case .standard:
                    return .standard
                case .condensed:
                    return .condensed
                case .expanded:
                    return .expanded
                case .compressed:
                    return .compressed
                }
            }
            
            return nil
        }
    }

    static func roundedSystemFont(ofSize size: CGFloat, weight: Weight) -> UIFont {
        let font: UIFont = .systemFont(ofSize: size, weight: weight)
        guard let descriptor = font.fontDescriptor.withDesign(.rounded) else {
            return font
        }

        return .init(descriptor: descriptor, size: font.pointSize)
    }

    static func compatibleSystemFont(ofSize size: CGFloat,
                                     weight: Weight = .regular,
                                     width: CompatibleWidth = .standard,
                                     design: UIFontDescriptor.SystemDesign? = nil) -> UIFont {
        let font: UIFont
        if #available(iOS 16.0, *) {
            font = .systemFont(ofSize: size, weight: weight, width: width.systemWidth ?? .standard)
        } else {
            font = .systemFont(ofSize: size, weight: weight)
        }

        guard let design = design,
              let descriptor = font.fontDescriptor.withDesign(design) else {
            return font
        }

        return .init(descriptor: descriptor, size: font.pointSize)
    }
}
