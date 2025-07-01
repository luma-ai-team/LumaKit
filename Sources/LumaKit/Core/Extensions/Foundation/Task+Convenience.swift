//
//  Task+Convenience.swift
//  LumaKit
//
//  Created by Anton Kormakov on 20.11.2024.
//

extension Task {

    @discardableResult
    public static func `do`(_ operation: @Sendable @escaping () async throws -> Void,
                            catch errorHandler: @Sendable @escaping (Error) async -> Void,
                            finally: (@Sendable () async -> Void)? = nil) -> Task<Void, Error> where Success == Void, Failure == Error {
        return Task {
            do {
                try await operation()
            }
            catch {
                await errorHandler(error)
            }

            await finally?()
        }
    }
}
