//
//  Copyright © 2024 . All rights reserved.
//

import GenericModule

final class ExamplePresenter: Presenter<ExampleState,
                                        ExampleViewController,
                                        ExampleModuleInput,
                                        ExampleModuleOutput,
                                        ExampleModuleDependencies> {
    //
}

// MARK: - ExampleViewOutput

extension ExamplePresenter: ExampleViewOutput {
    func randomValueEventTriggered() {
        state.value = UInt32.random(in: 0...UInt32.max)
        update(animated: true)

        output?.exampleModuleDidSomeStuff(self)
    }
}

// MARK: - ExampleModuleInput

extension ExamplePresenter: ExampleModuleInput {
    //
}

// MARK: - ExampleViewModelDelegate

extension ExamplePresenter: ExampleViewModelDelegate {
    //
}
