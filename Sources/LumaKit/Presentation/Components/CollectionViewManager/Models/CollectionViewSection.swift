//
//  Copyright © 2023 Draftz. All rights reserved.
//

import UIKit

public protocol CollectionViewSection {
    var items: [any CollectionViewItem] { get }
    var insets: UIEdgeInsets { get }
}

// MARK: - BasicCollectionViewSection

open class BasicCollectionViewSection: CollectionViewSection {
    public let items: [any CollectionViewItem]
    public var insets: UIEdgeInsets = .zero

    public init(items: [any CollectionViewItem]) {
        self.items = items
    }
}
