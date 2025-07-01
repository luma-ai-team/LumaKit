//
//  Copyright © 2025 . All rights reserved.
//

final class WebSearchState {
    let colorScheme: ColorScheme
    let materialStyle: MaterialStyle

    var isFetching: Bool = true
    var isLoadingNextPage: Bool = false
    var canLoadNextPage: Bool = false

    var key: WebSearchKey = .init(term: .init())
    var results: [any WebSearchResult] = []
    var error: Error?

    init(colorScheme: ColorScheme, materialStyle: MaterialStyle = .default) {
        self.colorScheme = colorScheme
        self.materialStyle = materialStyle
    }
}
