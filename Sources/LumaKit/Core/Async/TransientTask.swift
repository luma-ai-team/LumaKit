//
//  TransientTask.swift
//  LumaKit
//
//  Created by Anton Kormakov on 02.10.2024.
//

public final class TransientTask: Sendable {
    let task: Task<Void, Error>

    public init(_ operation: @escaping @Sendable () async throws -> Void) {
        task = Task(operation: operation)
    }

    deinit {
        task.cancel()
    }

    public func callAsFunction() {
        //
    }

    public func cancel() {
        task.cancel()
    }
}
