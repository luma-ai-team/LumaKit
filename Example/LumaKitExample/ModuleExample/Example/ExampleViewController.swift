//
//  Copyright © 2024 . All rights reserved.
//


import UIKit
import LumaKit
import GenericModule

protocol ExampleViewOutput: ViewOutput {
    func randomValueEventTriggered()
}

final class ExampleViewController: ViewController<ExampleViewModel, Any, ExampleViewOutput> {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Me"
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad {
            view.addSubview(titleLabel)
            view.bounds.size.height = 200.0
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        titleLabel.sizeToFit()
        titleLabel.center = view.bounds.center
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        output.randomValueEventTriggered()
    }

    override func update(with viewUpdate: Update<ViewModel>, animated: Bool) {
        viewUpdate(\.color) { (color: UIColor) in
            view.backgroundColor = color
            titleLabel.textColor = (color.yuv.y > 0.5) ? .black : .white
        }
    }
}
