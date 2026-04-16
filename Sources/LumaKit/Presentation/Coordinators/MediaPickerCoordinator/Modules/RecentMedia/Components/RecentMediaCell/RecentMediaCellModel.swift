//
//  RecentMediaCellModel.swift
//  LumaKit
//
//  Created by Anton K on 15.04.2026.
//

import UIKit

final class RecentMediaCellModel: Equatable {
    struct Metadata {
        let thumbnail: UIImage
        let duration: TimeInterval?
    }

    let item: MediaFetchService.Item
    let colorScheme: ColorScheme
    var metadata: Metadata?
    var isEditable: Bool = false
    var isSelectable: Bool = true

    init(item: MediaFetchService.Item, colorScheme: ColorScheme) {
        self.item = item
        self.colorScheme = colorScheme
    }

    static func empty(with colorScheme: ColorScheme) -> RecentMediaCellModel {
        return .init(item: .init(identifier: .init(), content: .image(.init())),
                     colorScheme: colorScheme)
    }

    static func == (lhs: RecentMediaCellModel, rhs: RecentMediaCellModel) -> Bool {
        return (lhs.item.identifier == rhs.item.identifier)
    }
}
