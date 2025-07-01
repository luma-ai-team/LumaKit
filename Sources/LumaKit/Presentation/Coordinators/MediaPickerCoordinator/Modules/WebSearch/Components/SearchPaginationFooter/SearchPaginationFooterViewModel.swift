//
//  SearchPaginationFooterViewModel.swift
//  LumaKit
//
//  Created by Anton K on 01.07.2025.
//

final class SearchPaginationFooterViewModel: Equatable {
    let colorScheme: ColorScheme

    init(colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }
    
    static func == (lhs: SearchPaginationFooterViewModel, rhs: SearchPaginationFooterViewModel) -> Bool {
        return true
    }
}
