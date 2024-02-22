//
//  Copyright © 2024 . All rights reserved.
//

import UIKit
import GenericModule

protocol ExampleViewModelDelegate: AnyObject {
    var state: ExampleState { get }
}

final class ExampleViewModel: ViewModel {
    let color: UIColor

    init(delegate: ExampleViewModelDelegate) {
        color = .p3(rgb: delegate.state.value)
    }
}
