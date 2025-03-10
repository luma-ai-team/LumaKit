//
//  ShareHandlerOverride.swift
//  LumaKit
//
//  Created by Anton K on 04.03.2025.
//

public final class ShareHandlerOverride {
    let destination: ShareDestination
    let handler: ([ShareContent]) async -> [ShareContent]

    public init(destination: ShareDestination, handler: @escaping ([ShareContent]) async -> [ShareContent]) {
        self.destination = destination
        self.handler = handler
    }
}
