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

    @UserDefault(key: "isAppRateCompleted", defaultValue: false, container: StoageServiceImp.container)
    var isAppRateCompleted: Bool

    init(dependencies: Dependencies) {
        //
    }
}
