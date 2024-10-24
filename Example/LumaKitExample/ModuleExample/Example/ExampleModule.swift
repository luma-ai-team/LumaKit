//
//  Copyright © 2024 . All rights reserved.
//


import GenericModule

@MainActor
protocol ExampleModuleInput {}

@MainActor
protocol ExampleModuleOutput {
    func exampleModuleDidSomeStuff(_ sender: ExampleModuleInput)
}

typealias ExampleModuleDependencies = Any

final class ExampleModule: Module<ExamplePresenter> {
    //
}
