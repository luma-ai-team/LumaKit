//
//  Copyright © 2023 Draftz. All rights reserved.
//

import UIKit

public protocol CollectionViewSection {
    var items: [any CollectionViewItem] { get }
    var insets: UIEdgeInsets { get }

    var header: (any CollectionViewSupplementaryItem)? { get }
    var footer: (any CollectionViewSupplementaryItem)? { get }
}

// MARK: - BasicCollectionViewSection

open class BasicCollectionViewSection: CollectionViewSection {
    public let items: [any CollectionViewItem]
    public var insets: UIEdgeInsets = .zero

    public var header: (any CollectionViewSupplementaryItem)?
    public var footer: (any CollectionViewSupplementaryItem)?

    public init(items: [any CollectionViewItem]) {
        self.items = items
    }

    public init<T: CollectionViewItem>(items: [T], selectionHandler: @escaping (T.Cell.ViewModel) -> Void) {
        self.items = items
        for item in items {
            item.selectionHandler = { _ in
                selectionHandler(item.viewModel)
            }
        }
    }
}

public extension BasicCollectionViewSection {
    static func uniform<T: CollectionViewCell>(cellType: T.Type,
                                               viewModels: [T.ViewModel],
                                               selectionHandler: @escaping (T.ViewModel) -> Void) -> BasicCollectionViewSection {
        let cellItems = viewModels.map { (viewModel: T.ViewModel) in
            let item = BasicCollectionViewItem<T>(viewModel: viewModel)
            item.selectionHandler = { _ in
                selectionHandler(viewModel)
            }
            return item
        }
        return BasicCollectionViewSection(items: cellItems)
    }
}
