//
//  StreamTask.swift
//  LumaKit
//
//  Created by Anton Kormakov on 13.11.2024.
//

public final class StreamTask<T>: Sendable {
    let task: Task<Void, Error>

    public init(pipe: AsyncPipe<T>, _ operation: @escaping @Sendable @isolated(any) (T) async throws -> Void) {
        task = Task {
            for await value in await pipe.makeStream() {
                guard Task.isCancelled == false else {
                    return
                }

                try await operation(value)
            }
        }
    }

    public init(stream: AsyncStream<T>, _ operation: @escaping @Sendable @isolated(any) (T) async throws -> Void) {
        task = Task {
            for await value in stream {
                guard Task.isCancelled == false else {
                    return
                }

                try await operation(value)
            }
        }
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
