//
//  Copyright © 2026 . All rights reserved.
//

final class RecentMediaState {
    let colorScheme: ColorScheme

    var items: [MediaFetchService.Item] = []
    var selectedItems: [MediaFetchService.Item] = []

    var filter: MediaRecentsService.RecordType?
    var expectedItemCount: Int = 0
    var selectionLimit: Int = 1
    var isEditingAllowed: Bool = true
    var isLoading: Bool = true

    init(colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }
}
