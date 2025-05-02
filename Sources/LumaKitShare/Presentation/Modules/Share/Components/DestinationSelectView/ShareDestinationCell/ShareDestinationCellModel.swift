//
//  ShareDestinationCellModel.swift
//  LumaKit
//
//  Created by Anton K on 04.03.2025.
//

import UIKit
import LumaKit

@MainActor
final class ShareDestinationCellModel {
    let colorScheme: ColorScheme
    let materialStyle: MaterialStyle
    let destination: ShareDestination

    init(colorScheme: ColorScheme, materialStyle: MaterialStyle = .default, destination: ShareDestination) {
        self.colorScheme = colorScheme
        self.materialStyle = materialStyle
        self.destination = destination
    }
}

extension ShareDestinationCellModel: @preconcurrency Equatable {
    static func == (lhs: ShareDestinationCellModel, rhs: ShareDestinationCellModel) -> Bool {
        return lhs.isEqual(to: rhs, keyPaths: [
            .init(keyPath: \.destination.title),
            .init(keyPath: \.destination.status)
        ])
    }
}
