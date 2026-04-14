//
//  Copyright © 2024 . All rights reserved.
//


import UIKit
import LumaKit
import GenericModule

@MainActor
protocol DummyMediaProviderViewOutput: ViewOutput {
    func imageEventTriggered()
}

final class DummyMediaProviderViewController: ViewController<DummyMediaProviderViewModel, Any, DummyMediaProviderViewOutput> {

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
        output.imageEventTriggered()
    }
}
