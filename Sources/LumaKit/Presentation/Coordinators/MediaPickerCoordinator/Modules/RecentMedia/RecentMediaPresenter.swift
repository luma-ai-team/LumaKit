//
//  Copyright © 2026 . All rights reserved.
//

import GenericModule

final class RecentMediaPresenter: Presenter<RecentMediaState,
                                            RecentMediaViewController,
                                            RecentMediaModuleInput,
                                            RecentMediaModuleOutput,
                                            RecentMediaModuleDependencies> {
    let provider: MediaRecentsService = .shared

    override func viewDidLoad() {
        if state.expectedItemCount == 0 {
            state.expectedItemCount = provider.recordCount(type: state.filter)
        }
        super.viewDidLoad()

        Task {
            state.items = try await provider.fetch(type: state.filter, limit: state.expectedItemCount)
            update(animated: false)
        }
    }
}

// MARK: - RecentMediaViewOutput

extension RecentMediaPresenter: RecentMediaViewOutput {
    func selectionEventTriggered(with item: MediaFetchService.Item) {
        if state.selectionLimit < 2 {
            output?.recentMediaModuleDidFinish(self, with: [item])
            return
        }

        if state.selectedItems.contains(item) {
            state.selectedItems.removeAll(matching: item)
        }
        else {
            state.selectedItems.append(item)
        }
        update(animated: false)
    }
    
    func deleteEventTriggered(with item: MediaFetchService.Item) {
        Task {
            try await provider.remove(item: item)
        }

        state.items.removeAll(matching: item)
        state.selectedItems.removeAll(matching: item)
        update(animated: false)

        if state.items.isEmpty {
            viewInput.dismiss()
        }
    }

    func confirmSelectionEventTriggered() {
        output?.recentMediaModuleDidFinish(self, with: state.selectedItems)
    }
}

// MARK: - RecentMediaModuleInput

extension RecentMediaPresenter: RecentMediaModuleInput {
    //
}

// MARK: - RecentMediaViewModelDelegate

extension RecentMediaPresenter: RecentMediaViewModelDelegate {
    //
}
