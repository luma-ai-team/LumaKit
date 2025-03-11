//
//  Copyright © 2025 . All rights reserved.
//

import LumaKit
import GenericModule

protocol FeedbackViewModelDelegate: AnyObject {
    var state: FeedbackState { get }
}

final class FeedbackViewModel: ViewModel {
    let colorScheme: ColorScheme
    let feedback: String
    let isActionAvailable: Bool
    let isSending: Bool

    init(delegate: FeedbackViewModelDelegate) {
        colorScheme = delegate.state.colorScheme
        feedback = delegate.state.feedback ?? .init()
        isActionAvailable = feedback.count > 5
        isSending = delegate.state.isSending
    }
}
