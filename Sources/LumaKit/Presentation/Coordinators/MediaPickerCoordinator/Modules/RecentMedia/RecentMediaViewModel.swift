//
//  Copyright © 2026 . All rights reserved.
//

import UIKit
import GenericModule

@MainActor
protocol RecentMediaViewModelDelegate: AnyObject {
    var state: RecentMediaState { get }
}

final class RecentMediaViewModel: ViewModel {
    let colorScheme: ColorScheme
    let cellModels: [RecentMediaCellModel]
    let selectedIndexPaths: [IndexPath]
    let filter: MediaRecentsService.RecordType?
    let expectedItemCount: Int
    let selectionLimit: Int
    let isEditingAllowed: Bool

    init(delegate: RecentMediaViewModelDelegate) {
        colorScheme = delegate.state.colorScheme
        cellModels = delegate.state.items.map { (item: MediaFetchService.Item) in
            let model = RecentMediaCellModel(item: item, colorScheme: delegate.state.colorScheme)
            model.isEditable = delegate.state.isEditingAllowed
            model.isSelectable = delegate.state.selectionLimit > 1
            return model
        }
        selectedIndexPaths = delegate.state.selectedItems.compactMap { (item: MediaFetchService.Item) in
            guard let index = delegate.state.items.firstIndex(of: item) else {
                return nil
            }

            return .init(row: index, section: 0)
        }

        filter = delegate.state.filter
        expectedItemCount = delegate.state.expectedItemCount
        selectionLimit = delegate.state.selectionLimit
        isEditingAllowed = delegate.state.isEditingAllowed
    }
}
