//
//  Copyright © 2025 . All rights reserved.
//

import GenericModule

protocol FeedbackViewModelDelegate: AnyObject {
    var state: FeedbackState { get }
}

final class FeedbackViewModel: ViewModel {

    init(delegate: FeedbackViewModelDelegate) {
        //
    }
}