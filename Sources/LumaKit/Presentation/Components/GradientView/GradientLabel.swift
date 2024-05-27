//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class GradientLabel: UILabel {
    open var gradient: Gradient = .horizontal(colors: [.black]) {
        didSet {
            setNeedsDisplay()
        }
    }

    open override func tintColorDidChange() {
        super.tintColorDidChange()
        setNeedsDisplay()
    }

    open override func drawText(in rect: CGRect) {
        let textRect = textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        textColor = .init(patternImage: makeGradientImage(in: textRect))
        super.drawText(in: rect)
    }

    open func makeGradientImage(in rect: CGRect) -> UIImage {
        let gradientRect = CGRect(origin: .zero, size: rect.size)
        let gradientRenderer = UIGraphicsImageRenderer(bounds: gradientRect)
        let gradientImage = gradientRenderer.image { (context: UIGraphicsImageRendererContext) in
            var colors = gradient.colors
            let isDimmed = self.isDimmed || (isEnabled == false)
            if isDimmed {
                colors = colors.map { (color: UIColor) in
                    return .init(white: color.yuv.y, alpha: color.alpha)
                }
            }

            let cgColors = colors.map(\.cgColor) as CFArray
            var locations: [CGFloat] = gradient.resolveLocations().map { (location: Double) in
                return CGFloat(location)
            }
            guard let cgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                              colors: cgColors,
                                              locations: &locations) else {
                return
            }

            context.cgContext.drawLinearGradient(cgGradient,
                                                 start: gradient.startPoint * gradientRect.size,
                                                 end: gradient.endPoint * gradientRect.size,
                                                 options: [])
        }

        let canvasRenderer = UIGraphicsImageRenderer(bounds: bounds)
        let canvasImage = canvasRenderer.image { (context: UIGraphicsImageRendererContext) in
            UIGraphicsPushContext(context.cgContext)
            gradientImage.draw(in: .init(x: rect.minX, y: bounds.midY - rect.midY, width: rect.width, height: rect.height))
            UIGraphicsPopContext()
        }
        return canvasImage
    }
}
