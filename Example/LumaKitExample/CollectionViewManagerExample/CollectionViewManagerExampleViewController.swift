//
//  CollectionViewManagerExampleView.swift
//  LumaKitExample
//
//  Created by Anton Kormakov on 14.02.2024.
//

import UIKit
import LumaKit

final class CollectionViewManagerExampleViewController: AutoSelectionCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupCollection()
    }

    private func setupCollection() {
        let aSection = BasicCollectionViewSection(items: [
            BasicCollectionViewItem<TestCell>(viewModel: .init(color: 0xFF0000)),
            BasicCollectionViewItem<TestCell>(viewModel: .init(color: 0x00FF00)),
            BasicCollectionViewItem<TestCell>(viewModel: .init(color: 0x0000FF))
        ])
        aSection.insets.right = 20.0

        let bSection = BasicCollectionViewSection(items: [
            BasicCollectionViewItem<LayoutCell>(viewModel: .init(color: 0xFFFF00)),
            BasicCollectionViewItem<LayoutCell>(viewModel: .init(color: 0x00FFFF)),
            BasicCollectionViewItem<LayoutCell>(viewModel: .init(color: 0xFF00FF))
        ])

        manager.sections = [aSection, bSection]
        manager.select(aSection.items[1], scrollPosition: .centeredHorizontally)
        manager.selectionHandler = { (item: CollectionViewItem) in
            print(item.viewModel)
        }
    }
}
