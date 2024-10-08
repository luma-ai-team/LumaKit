//
//  AsyncPipe.swift
//  LumaKit
//
//  Created by Anton Kormakov on 02.10.2024.
//

import Foundation

public protocol AsyncSink: Actor {
    associatedtype T
    func send(_ value: T)
}

public protocol AsyncSource: Actor {
    associatedtype T
    func makeStream() -> AsyncStream<T>
}

public actor AsyncPipe<T>: AsyncSink, AsyncSource {
    public private(set) var value: T
    private var sinks: [UUID: AsyncStream<T>.Continuation] = [:]

    public init(value: T) {
        self.value = value
    }

    public func makeStream() -> AsyncStream<T> {
        return .init(bufferingPolicy: .bufferingNewest(1)) { (continuation: AsyncStream<T>.Continuation) in
            self.register(continuation)
        }
    }

    private func register(_ sink: AsyncStream<T>.Continuation) {
        let identifier = UUID()
        sinks[identifier] = sink
        sink.yield(value)

        sink.onTermination = { (termination: AsyncStream<T>.Continuation.Termination) in
            Task {
                await self.removeSink(withIdentifier: identifier)
            }
        }
    }

    private func removeSink(withIdentifier identifier: UUID) {
        sinks[identifier] = nil
    }

    public func send(_ value: T) {
        self.value = value
        for sink in sinks.values {
            sink.yield(value)
        }
    }

    public func finish() {
        for sink in sinks.values {
            sink.finish()
        }
    }
}
