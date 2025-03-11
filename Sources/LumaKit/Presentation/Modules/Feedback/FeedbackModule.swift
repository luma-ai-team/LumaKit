//
//  Copyright © 2025 . All rights reserved.
//

import GenericModule

protocol FeedbackModuleInput {
    var state: FeedbackState { get }
    func update(force: Bool, animated: Bool)
}

protocol FeedbackModuleOutput {
    //
}

typealias FeedbackModuleDependencies = Any

final class FeedbackModule: Module<FeedbackPresenter> {
    //
}