//
//  AsyncPipe.swift
//  LumaKit
//
//  Created by Anton Kormakov on 02.10.2024.
//

public protocol AsyncSink {
    associatedtype T
    func send(_ value: T)
}

public protocol AsyncSource {
    associatedtype T
    var stream: AsyncStream<T> { get }
}

public final class AsyncPipe<T>: AsyncSink, AsyncSource {
    public let stream: AsyncStream<T>
    var sink: AsyncStream<T>.Continuation

    public init(bufferingPolicy: AsyncStream<T>.Continuation.BufferingPolicy = .bufferingNewest(1)) {
        var sink: AsyncStream<T>.Continuation!
        stream = .init (bufferingPolicy: bufferingPolicy) { (continuation: AsyncStream<T>.Continuation) in
            sink = continuation
        }

        self.sink = sink
    }

    deinit {
        sink.finish()
    }

    public func send(_ value: T) {
        sink.yield(value)
    }

    public func finish() {
        sink.finish()
    }
}
