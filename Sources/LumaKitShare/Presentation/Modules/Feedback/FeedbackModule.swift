//
//  Copyright © 2025 . All rights reserved.
//

import GenericModule

@MainActor
protocol FeedbackModuleInput {
    var state: FeedbackState { get }
    func update(force: Bool, animated: Bool)
}

@MainActor
protocol FeedbackModuleOutput {
    func feedbackModuleDidRequestSend(_ input: FeedbackModuleInput, feedback: String) async
}

typealias FeedbackModuleDependencies = Any

final class FeedbackModule: Module<FeedbackPresenter> {
    //
}
