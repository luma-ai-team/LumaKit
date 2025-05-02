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
    let materialStyle: MaterialStyle
    let feedback: String
    let isActionAvailable: Bool
    let isPlaceholderHidden: Bool
    let isSending: Bool

    init(delegate: FeedbackViewModelDelegate) {
        colorScheme = delegate.state.colorScheme
        materialStyle = delegate.state.materialStyle
        feedback = delegate.state.feedback ?? .init()
        isActionAvailable = feedback.count > 5
        isPlaceholderHidden = feedback.isEmpty == false
        isSending = delegate.state.isSending
    }
}
