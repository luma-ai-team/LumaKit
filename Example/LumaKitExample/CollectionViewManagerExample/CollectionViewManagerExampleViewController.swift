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
        ], selectionHandler: { (viewModel: TestViewModel) in
            print(viewModel)
        })
        aSection.insets.right = 20.0

        let viewModels: [LayoutCell.ViewModel] = [
            .init(color: 0xFFFF00),
            .init(color: 0x00FFFF),
            .init(color: 0xFF00FF)
        ]
        let bSection = BasicCollectionViewSection.uniform(cellType: LayoutCell.self,
                                                          viewModels: viewModels) { (viewModel: TestViewModel) in
            print(viewModel)
        }

        manager.sections = [aSection, bSection]
        manager.select(aSection.items[1], scrollPosition: .centeredHorizontally)
        manager.selectionHandler = { (item: CollectionViewItem) in
            print(item.viewModel)
        }
    }
}
