//
//  Services.swift
//  LumaKit
//
//  Created by Anton K on 11.03.2025.
//

import LumaKit

typealias HasAllServices = HasStorageService

// swiftlint:disable:next identifier_name
let Services: HasAllServices = ServiceFactory()

private class ServiceFactory: LumaKit.ServiceFactory, HasAllServices {
    lazy var storageService: any StorageService = provide(StoageServiceImp.self, scope: .shared)
}
