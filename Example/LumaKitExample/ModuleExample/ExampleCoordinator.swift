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

    lazy var transientTask: TransientTask = .init({ [weak self] in
        repeat {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            await self?.pipe.send(Int.random(in: 0...100))
        } while true
    })

    lazy var anotherTransientTask: TransientTask = .init { [weak self] in
        for await value in try await self.unwrap().pipe.makeStream() {
            print("Task 1", value)
        }
    }

    lazy var oneMoreTransientTask: TransientTask = .init { [weak self] in
        for await value in try await self.unwrap().pipe.makeStream() {
            print("Task 2", value)
        }
    }

    lazy var pipe: AsyncPipe<Int> = .init(value: 0)
    lazy var streamTask: StreamTask<Int> = .init(pipe: pipe) { (value: Int) in
        print("Stream Task", value)
    }

    deinit {
        print("ExampleCoordinator deinit")
    }

    override func start(with state: Module<ExamplePresenter>.State, dependencies: ExampleModuleDependencies) -> ExampleModule {
        transientTask()
        anotherTransientTask()
        oneMoreTransientTask()
        streamTask()

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

    @Sendable
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
