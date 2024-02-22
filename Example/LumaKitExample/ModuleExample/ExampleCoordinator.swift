//
//  ExampleCoordinator.swift
//  LumaKitExample
//
//  Created by Anton Kormakov on 22.02.2024.
//

import UIKit
import GenericModule

final class ExampleCoordinator: Coordinator<UIViewController> {

    deinit {
        print("ExampleCoordinator deinit")
    }

    func start() {
        let module = ExampleModule(state: .init(), dependencies: [], output: self)
        rootViewController.present(module.viewController, animated: true)
    }
}

// MARK: - ExampleModuleOutput

extension ExampleCoordinator: ExampleModuleOutput {
    func exampleModuleDidSomeStuff(_ sender: ExampleModuleInput) {
        print("ExampleModule did some stuff")
    }
}
