//
//  StorageServiceImp.swift
//  LumaKit
//
//  Created by Anton K on 11.03.2025.
//

import LumaKit
import Foundation

final class StoageServiceImp: StorageService {
    typealias Dependencies = Any
    static let container: UserDefaults = .init(suiteName: "ai.luma.kit.share") ?? .standard

    var isAppFeedbackPending: Bool {
        return feedbackAppVersion != currentAppVersion
    }

    var isVersionTrackingEnabled: Bool = false

    @UserDefault(key: "feedbackAppVersion", defaultValue: nil, container: StoageServiceImp.container)
    private var feedbackAppVersion: String?

    private var currentAppVersion: String {
        guard isVersionTrackingEnabled else {
            return "universal"
        }

        return "\(Bundle.main.appVersion)/\(Bundle.main.buildIdentifier ?? .init())"
    }

    init(dependencies: Dependencies) {
        //
    }

    func markAppFeedbackAcquired() {
        feedbackAppVersion = currentAppVersion
    }
}
