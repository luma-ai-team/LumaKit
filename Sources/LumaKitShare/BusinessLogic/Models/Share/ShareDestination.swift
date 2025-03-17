//
//  ShareDestination.swift
//  LumaKit
//
//  Created by Anton K on 03.03.2025.
//

import UIKit

public enum ShareDestinationError: Error {
    case cancelled
}

@MainActor
public protocol ShareDestination {
    var identifier: String { get }
    var title: String { get }
    var icon: UIImage? { get }
    var status: ShareStatus { get }

    func canShare(_ content: [ShareContent]) -> Bool
    func share(_ content: [ShareContent], in context: ShareContext) async throws
}
