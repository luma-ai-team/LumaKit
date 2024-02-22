//
//  CollectionViewManagerExampleView.swift
//  LumaKitExample
//
//  Created by Anton Kormakov on 14.02.2024.
//

import UIKit
import LumaKit

final class CollectionViewManagerExampleViewController: UIViewController {

    private lazy var collectionViewManager: CollectionViewManager = {
        let manager = CollectionViewManager(collectionView: collectionView)
        manager.ignoresSelectionEventsDuringDragging = true
        return manager
    }()

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = ScrollSelectCollectionViewLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(collectionView)

        setupCollection()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
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

        collectionViewManager.sections = [aSection, bSection]
        collectionViewManager.select(aSection.items[1], scrollPosition: .centeredHorizontally)
        collectionViewManager.selectionHandler = { (item: CollectionViewItem) in
            print(item.viewModel)
        }
    }
}
