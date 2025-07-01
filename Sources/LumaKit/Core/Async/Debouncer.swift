//
//  Debouncer.swift
//  LumaKit
//
//  Created by Anton K on 30.06.2025.
//

import Foundation

public final class Debouncer {
    public var initialDelay: TimeInterval
    public var overlapDelay: TimeInterval

    private var task: Task<Void, Error>?

    public init(initialDelay: TimeInterval, overlapDelay: TimeInterval) {
        self.initialDelay = initialDelay
        self.overlapDelay = overlapDelay
    }

    public init(delay: TimeInterval) {
        self.initialDelay = delay
        self.overlapDelay = delay
    }

    public func run(_ handler: @escaping () async throws -> Void) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        let delay: TimeInterval = (task == nil) ? initialDelay : overlapDelay
        task?.cancel()

        task = Task {
            defer {
                if Task.isCancelled == false {
                    self.task = nil
                }
            }

            try await Task.sleep(nanoseconds: .init(delay * 1_000_000_000))
            guard Task.isCancelled == false else {
                return
            }

            try await handler()
        }
    }
}
