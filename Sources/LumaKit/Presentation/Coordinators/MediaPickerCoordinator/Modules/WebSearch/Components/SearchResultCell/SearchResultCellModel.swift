//
//  SearchResultCellModel.swift
//  LumaKit
//
//  Created by Anton K on 27.06.2025.
//

import UIKit

final class SearchResultCellModel {
    let colorScheme: ColorScheme
    let materialStyle: MaterialStyle
    let result: any WebSearchResult
    let asset: AssetProvider.Asset<UIImage>
    var image: UIImage?

    init(colorScheme: ColorScheme,
         materialStyle: MaterialStyle,
         result: any WebSearchResult,
         asset: AssetProvider.Asset<UIImage>) {
        self.colorScheme = colorScheme
        self.materialStyle = materialStyle
        self.result = result
        self.asset = asset
        self.image = asset.cached
    }
}

extension SearchResultCellModel: Equatable {
    static func == (lhs: SearchResultCellModel, rhs: SearchResultCellModel) -> Bool {
        return lhs.isEqual(to: rhs, keyPaths: [
            .init(keyPath: \.result.url),
            .init(keyPath: \.result.size)
        ])
    }
}
