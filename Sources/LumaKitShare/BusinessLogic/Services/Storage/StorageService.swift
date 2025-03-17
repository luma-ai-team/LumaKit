//
//  StorageService.swift
//  LumaKit
//
//  Created by Anton K on 11.03.2025.
//

import LumaKit

public protocol HasStorageService {
    var storageService: any StorageService { get }
}

public protocol StorageService: ServiceInitializable {
    var isVersionTrackingEnabled: Bool { get set }
    var isAppFeedbackPending: Bool { get }

    func markAppFeedbackAcquired()
}
