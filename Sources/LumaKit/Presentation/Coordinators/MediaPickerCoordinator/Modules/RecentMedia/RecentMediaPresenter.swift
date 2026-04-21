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

    private lazy var recentsUpdateTask: StreamTask = {
        let pipe = provider.recentsUpdatePipe
        return .init(pipe: pipe) { [weak self] _ in
            await self?.updateRecents()
        }
    }()

    override func viewDidLoad() {
        if state.expectedItemCount == 0 {
            state.expectedItemCount = provider.recordCount(type: state.filter)
        }

        super.viewDidLoad()
        recentsUpdateTask()
    }

    private func updateRecents() {
        Task {
            state.items = try await provider.fetch(type: state.filter, limit: state.expectedItemCount)
            state.isLoading = false
            update(animated: false)
        }
    }
}

// MARK: - RecentMediaViewOutput

extension RecentMediaPresenter: RecentMediaViewOutput {
    func selectionEventTriggered(with item: MediaFetchService.Item) {
        if state.selectionLimit < 2 {
            recentsUpdateTask.cancel()
            output?.recentMediaModuleDidFinish(self, with: [item])
            return
        }

        if state.selectedItems.contains(item) {
            state.selectedItems.removeAll(matching: item)
        }
        else if state.selectedItems.count < state.selectionLimit {
            state.selectedItems.append(item)
        }

        update(animated: false)
    }
    
    func deleteEventTriggered(with item: MediaFetchService.Item) {
        state.items.removeAll(matching: item)
        update(animated: false)

        Task {
            try await provider.remove(item: item)
            output?.recentMediaModuleDidUpdateRecents(self)
        }

        if state.items.isEmpty {
            viewInput.dismiss()
        }
    }

    func confirmSelectionEventTriggered() {
        recentsUpdateTask.cancel()
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
