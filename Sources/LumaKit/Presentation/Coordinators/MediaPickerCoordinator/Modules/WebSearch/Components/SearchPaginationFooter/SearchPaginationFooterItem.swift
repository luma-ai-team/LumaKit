//
//  SearchPaginationFooterItem.swift
//  LumaKit
//
//  Created by Anton K on 01.07.2025.
//

import UIKit

final class SearchPaginationFooterItem: BasicCollectionViewSupplementaryItem<SearchPaginationFooterView> {
    var willDisplayHandler: (() -> Void)?

    override func willDisplay(_ view: SearchPaginationFooterView,
                              in collectionView: UICollectionView,
                              indexPath: IndexPath) {
        super.willDisplay(view, in: collectionView, indexPath: indexPath)
        willDisplayHandler?()
    }
}
