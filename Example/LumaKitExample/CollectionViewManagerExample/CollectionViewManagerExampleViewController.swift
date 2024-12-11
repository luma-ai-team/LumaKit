//
//  CollectionViewManagerExampleView.swift
//  LumaKitExample
//
//  Created by Anton Kormakov on 14.02.2024.
//

import UIKit
import LumaKit

final class CollectionViewManagerExampleViewController: CollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupCollection()
    }

    private func setupCollection() {
        let cellItemWithActions = BasicCollectionViewItem<TestCell>(viewModel: .init(color: 0xFF0000))
        cellItemWithActions.contextActions = [
            .init(title: "Do Something!", handler: { _ in
                print("I did something")
            })
        ]

        let aSection = BasicCollectionViewSection(items: [
            cellItemWithActions,
            BasicCollectionViewItem<TestCell>(viewModel: .init(color: 0x00FF00)),
            BasicCollectionViewItem<TestCell>(viewModel: .init(color: 0x0000FF))
        ], selectionHandler: { (viewModel: TestViewModel) in
            print(viewModel)
        })
        aSection.insets.right = 20.0
        aSection.header = BasicCollectionViewSupplementaryItem<HeaderView>(viewModel: "hello")
        aSection.footer = BasicCollectionViewSupplementaryItem<HeaderView>(viewModel: "world")

        let viewModels: [LayoutCell.ViewModel] = [
            .init(color: 0xFFFF00),
            .init(color: 0x00FFFF),
            .init(color: 0xFF00FF)
        ]
        let bSection = BasicCollectionViewSection.uniform(cellType: LayoutCell.self,
                                                          viewModels: viewModels) { (viewModel: TestViewModel) in
            print(viewModel)
        }
        bSection.header = BasicCollectionViewSupplementaryItem<HeaderView>(viewModel: "header")
        bSection.footer = BasicCollectionViewSupplementaryItem<HeaderView>(viewModel: "footer")

        manager.update(with: [aSection, bSection])
        manager.select(aSection.items[1], scrollPosition: .centeredHorizontally)
        manager.selectionHandler = { (item: CollectionViewCellItem) in
            print(item.viewModel)
        }

        #if targetEnvironment(macCatalyst)
        collectionView.allowsMultipleSelection = true
        manager.simulatesiOSMultiSelectionBehavior = true
        #endif

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.performPartialUpdate()
        }
    }

    func performPartialUpdate() {
        let cellItemWithActions = BasicCollectionViewItem<TestCell>(viewModel: .init(color: 0xFF0000))
        cellItemWithActions.contextActions = [
            .init(title: "Do Something!", handler: { _ in
                print("I did something")
            })
        ]

        let aSection = BasicCollectionViewSection(items: [
            cellItemWithActions,
            BasicCollectionViewItem<TestCell>(viewModel: .init(color: 0x000000)),
            BasicCollectionViewItem<TestCell>(viewModel: .init(color: 0x0000FF))
        ], selectionHandler: { (viewModel: TestViewModel) in
            print(viewModel)
        })
        aSection.insets.right = 20.0
        aSection.header = BasicCollectionViewSupplementaryItem<HeaderView>(viewModel: "hello")
        aSection.footer = BasicCollectionViewSupplementaryItem<HeaderView>(viewModel: "world")

        let viewModels: [LayoutCell.ViewModel] = [
            .init(color: 0xFFFF00),
            .init(color: 0xFFFFFF)
        ]
        let bSection = BasicCollectionViewSection.uniform(cellType: LayoutCell.self,
                                                          viewModels: viewModels) { (viewModel: TestViewModel) in
            print(viewModel)
        }
        bSection.header = BasicCollectionViewSupplementaryItem<HeaderView>(viewModel: "schmeader")
        bSection.footer = BasicCollectionViewSupplementaryItem<HeaderView>(viewModel: "footer")

        manager.update(with: [aSection, bSection])
    }
}
