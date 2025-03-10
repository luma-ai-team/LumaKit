//
//  Copyright © 2025 . All rights reserved.
//

import GenericModule

final class FeedbackPresenter: Presenter<FeedbackState,
                                         FeedbackViewController,
                                         FeedbackModuleInput,
                                         FeedbackModuleOutput,
                                         FeedbackModuleDependencies> {
    //
}

// MARK: - FeedbackViewOutput

extension FeedbackPresenter: FeedbackViewOutput {
    func feedbackEditEventTriggered(feedback: String) {
        state.feedback = feedback
        update(animated: false)
    }

    func submitEventTriggered(feedback: String) {
        state.isSending = true
        update(animated: false)

        Task {
            await output?.feedbackModuleDidRequestSend(self, feedback: feedback)
        }
    }
}

// MARK: - FeedbackModuleInput

extension FeedbackPresenter: FeedbackModuleInput {
    //
}

// MARK: - FeedbackViewModelDelegate

extension FeedbackPresenter: FeedbackViewModelDelegate {
    //
}
