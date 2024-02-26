//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class GradientButton: BounceButton {
    public var gradient: Gradient = .horizontal(colors: [.clear]) {
        didSet {
            gradientView.gradient = gradient
        }
    }

    open override var isEnabled: Bool {
        didSet {
            gradientView.isEnabled = isEnabled
        }
    }

    private lazy var gradientView: GradientView = {
        let view = GradientView(gradient: gradient)
        view.isUserInteractionEnabled = false
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        clipsToBounds = true
        insertSubview(gradientView, at: 0)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.frame = bounds
    }
}
