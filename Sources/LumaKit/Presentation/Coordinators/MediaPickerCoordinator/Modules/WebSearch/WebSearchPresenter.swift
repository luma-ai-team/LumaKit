//
//  Copyright © 2025 . All rights reserved.
//

import GenericModule

final class WebSearchPresenter: Presenter<WebSearchState,
                                          WebSearchViewController,
                                          WebSearchModuleInput,
                                          WebSearchModuleOutput,
                                          WebSearchModuleDependencies> {
    static let assetProvider: AssetProvider = .init(scope: "WebSearch", isTemporary: true)
    let debouncer: Debouncer = .init(delay: 0.5)
    var cache: LazyCache<WebSearchKey, [any WebSearchResult]> = .init()


    override func viewDidLoad() {
        super.viewDidLoad()
        searchEventTriggered(term: state.key.term)
    }
}

// MARK: - WebSearchViewOutput

extension WebSearchPresenter: WebSearchViewOutput {
    func dismissEventTriggered() {
        dependencies.cancel()
        output?.webSearchModuleDidDismiss(self)
    }

    func searchEventTriggered(term: String) {
        let key = WebSearchKey(term: term)
        state.key = key
        state.isFetching = true
        update(animated: false)

        debouncer.run { [self] in
            do {
                state.results = try await cache.fetch(for: key, provider: dependencies.search)
                guard state.key == key else {
                    return
                }

                state.canLoadNextPage = state.results.isEmpty == false
                state.error = nil
            }
            catch {
                state.canLoadNextPage = false
                state.results = []
                state.error = error
            }

            state.isFetching = false
            update(animated: true)
        }
    }

    func selectionEventTriggered(_ result: any WebSearchResult) {
        Task {
            do {
                let image = try await assetProvider.fetchImageAsset(at: result.url,
                                                                    identifier: result.identifier).resolve()
                output?.webSearchModuleDidFinish(self, with: image)
            }
            catch {
                output?.webSearchModuleDidFail(self, with: error)
            }
        }
    }

    func nextPageEventTriggered() {
        guard state.isLoadingNextPage == false else {
            return
        }

        state.isLoadingNextPage = true
        let key = WebSearchKey(term: state.key.term, index: state.results.count)
        state.key = key

        Task {
            do {
                let results = try await cache.fetch(for: key, provider: dependencies.search)
                guard state.key == key else {
                    return
                }

                state.canLoadNextPage = results.isEmpty == false
                state.results.append(contentsOf: results)
                state.error = nil
            }
            catch {
                state.canLoadNextPage = false
            }

            state.isLoadingNextPage = false
            update(animated: true)
        }
    }
}

// MARK: - WebSearchModuleInput

extension WebSearchPresenter: WebSearchModuleInput {
    //
}

// MARK: - WebSearchViewModelDelegate

extension WebSearchPresenter: WebSearchViewModelDelegate {
    var assetProvider: AssetProvider {
        return Self.assetProvider
    }

    var searchSource: String {
        return dependencies.source
    }
}
