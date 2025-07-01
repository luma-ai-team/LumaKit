//
//  WebSearchResult.swift
//  LumaKit
//
//  Created by Anton K on 27.06.2025.
//

import UIKit

public protocol WebSearchResult: Codable {
    var identifier: String { get }
    var url: URL { get }
    var size: CGSize { get }
}
