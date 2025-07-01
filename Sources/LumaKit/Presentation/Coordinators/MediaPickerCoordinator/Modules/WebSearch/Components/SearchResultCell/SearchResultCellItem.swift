//
//  SearchResultCellItem.swift
//  LumaKit
//
//  Created by Anton K on 27.06.2025.
//

import UIKit

final class SearchResultCellItem: LazyCollectionViewItem<SearchResultCell> {
    override init(viewModel: SearchResultCellModel) {
        super.init(viewModel: viewModel)
        updateMethod = .reconfigure
    }
}
