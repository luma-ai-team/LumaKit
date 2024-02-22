//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public class GradientProgressView: UIView {
    
    public enum Animation {
        case none
        case easeInOut(duration: TimeInterval = 0.25)
        case spring(duration: TimeInterval = 0.35)
    }

    public private(set) var progress: Double = 0.0

    public var gradient: Gradient {
        get {
            return gradientView.gradient
        }
        set {
            gradientView.gradient = newValue
            layout()
        }
    }

    private lazy var gradientView: GradientView = .init()

    public init(colorScheme: ColorScheme) {
        super.init(frame : .zero)
        backgroundColor = colorScheme.genericAction.inactive
        gradient = colorScheme.gradient.primary
        setup()
    }

    public init() {
        super.init(frame: .zero)
        setup()
    }

    public init(gradient: Gradient) {
        super.init(frame : .zero)
        self.gradient = gradient
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        clipsToBounds = true
        addSubview(gradientView)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.midY
        gradientView.frame = .init(x: 0.0, y: 0.0, width: bounds.width * progress, height: bounds.height)
        gradientView.layer.cornerRadius = gradientView.bounds.midY
    }

    public func setProgress(progress: Double, animation: Animation) {
        self.progress = progress
        switch animation {
        case .none:
            layout()
        case let .easeInOut(duration: duration):
            UIView.animate(withDuration: duration) {
                self.layout()
            }
        case let .spring(duration: duration):
            UIView.defaultSpringAnimation(duration: duration) {
                self.layout()
            }
        }
    }
}
