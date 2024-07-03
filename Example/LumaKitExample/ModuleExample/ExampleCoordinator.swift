//
//  ExampleCoordinator.swift
//  LumaKitExample
//
//  Created by Anton Kormakov on 22.02.2024.
//

import UIKit
import LumaKit
import GenericModule

final class ExampleCoordinator: SheetCoordinator<ExampleModule, ExamplePresenter> {

    deinit {
        print("ExampleCoordinator deinit")
    }
}

// MARK: - ExampleModuleOutput

extension ExampleCoordinator: ExampleModuleOutput {
    func exampleModuleDidSomeStuff(_ sender: ExampleModuleInput) {
        print("ExampleModule did some stuff")
    }
}
