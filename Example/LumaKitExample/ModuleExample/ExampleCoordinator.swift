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

    lazy var lazyAsyncValue: Lazy<String> = .init(provider: {
        return try await self.fetchRandomValue(key: "lazy")
    })

    lazy var lazyAsyncCollection: LazyCollection<String, String> = .init()

    deinit {
        print("ExampleCoordinator deinit")
    }

    override func start(with state: Module<ExamplePresenter>.State, dependencies: ExampleModuleDependencies) -> ExampleModule {
        Task {
            print("Waiting for some stuff to be completed")
            print(try await lazyAsyncValue.fetch())
            print(try await lazyAsyncCollection.fetch(for: "one", provider: fetchRandomValue))
            print(try await lazyAsyncCollection.fetch(for: "two", provider: fetchRandomValue))
            print(try await lazyAsyncCollection.fetch(for: "three", provider: fetchRandomValue))
            print(try await lazyAsyncCollection.fetch(for: "one", provider: fetchRandomValue))
            print("Now all stuff is done, so I'm ready to be deallocated...")
        }

        return super.start(with: state, dependencies: dependencies)
    }

    private func fetchRandomValue(key: String) async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "\(key): some value (totally random)"
    }
}

// MARK: - ExampleModuleOutput

extension ExampleCoordinator: ExampleModuleOutput {
    func exampleModuleDidSomeStuff(_ sender: ExampleModuleInput) {
        print("ExampleModule did some stuff")
    }
}
