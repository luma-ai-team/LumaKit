//
//  Copyright © 2025 . All rights reserved.
//

import GenericModule

protocol WebSearchViewModelDelegate: AnyObject {
    var state: WebSearchState { get }
    var assetProvider: AssetProvider { get }
    var searchSource: String { get }
}

final class WebSearchViewModel: ViewModel {
    let colorScheme: ColorScheme
    let materialStyle: MaterialStyle
    let searchSource: String

    let isFetching: Bool
    let canLoadNextPage: Bool

    let term: String
    let status: String?
    let results: [SearchResultCellModel]

    init(delegate: WebSearchViewModelDelegate) {
        colorScheme = delegate.state.colorScheme
        materialStyle = delegate.state.materialStyle
        searchSource = delegate.searchSource

        isFetching = delegate.state.isFetching
        canLoadNextPage = delegate.state.canLoadNextPage

        term = delegate.state.key.term
        results = delegate.state.results.map { (result: any WebSearchResult) in
            let asset = delegate.assetProvider.fetchImageAsset(at: result.url,
                                                               identifier: result.identifier)
            return .init(colorScheme: delegate.state.colorScheme,
                         materialStyle: delegate.state.materialStyle,
                         result: result,
                         asset: asset)
        }

        if let error = delegate.state.error {
            status = "Something went wrong, please try again later\n\(error.localizedDescription)"
        }
        else if delegate.state.results.isEmpty,
             isFetching == false {
            status = "Nothing found"
        }
        else {
            status = nil
        }
    }
}
