//
//  Copyright © 2024 . All rights reserved.
//

import UIKit
import GenericModule

@MainActor
protocol DummyMediaProviderViewModelDelegate: AnyObject {
    var state: DummyMediaProviderState { get }
}

final class DummyMediaProviderViewModel: ViewModel {
    init(delegate: DummyMediaProviderViewModelDelegate) {
        //
    }
}
