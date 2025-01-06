//
//  LazyCollectionViewCellItem.swift
//  LumaKit
//
//  Created by Anton Kormakov on 06.01.2025.
//

import UIKit

open class LazyCollectionViewItem<Cell: CollectionViewCell>: CollectionViewCellItem {
    final class LazyKeyPath {
        private let handler: (inout Cell.ViewModel) async -> Bool

        init<T>(keyPath: WritableKeyPath<Cell.ViewModel, T?>, provider: @escaping () async throws -> T) {
            handler = { (viewModel: inout Cell.ViewModel) async in
                guard viewModel[keyPath: keyPath] == nil else {
                    return false
                }

                do {
                    viewModel[keyPath: keyPath] = try await provider()
                    return true
                }
                catch {
                    return false
                }
            }
        }

        func update(with viewModel: inout Cell.ViewModel) async -> Bool {
            return await handler(&viewModel)
        }
    }

    public var viewModel: Cell.ViewModel
    public var attributes: CollectionViewItemAttributes = .init()
    public var contextActions: [UIAction] = []

    public var selectionHandler: ((LazyCollectionViewItem) -> Void)?
    public var deselectionHandler: ((LazyCollectionViewItem) -> Void)?

    private var lazyKeyPaths: [LazyKeyPath] = []

    public init(viewModel: Cell.ViewModel) {
        self.viewModel = viewModel
    }

    @MainActor
    public func registerLazyKeyPath<T>(_ keyPath: WritableKeyPath<Cell.ViewModel, T?>,
                                       provider: @escaping () async throws -> T) {
        lazyKeyPaths.append(LazyKeyPath(keyPath: keyPath, provider: provider))
    }

    @MainActor
    open func configure(_ cell: Cell, in collectionView: UICollectionView, indexPath: IndexPath) {
        cell.update(with: viewModel, attributes: attributes)

        for lazyKeyPath in lazyKeyPaths {
            Task {
                guard await lazyKeyPath.update(with: &viewModel) else {
                    return
                }

                let isSelected = collectionView.indexPathsForSelectedItems?.contains(indexPath)
                collectionView.reloadItems(at: [indexPath])
                if isSelected == true {
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }
        }
    }

    @MainActor
    open func willDisplay(_ cell: Cell, in collectionView: UICollectionView, indexPath: IndexPath) {
        //
    }

    @MainActor
    open func didEndDisplay(_ cell: Cell, in collectionView: UICollectionView, indexPath: IndexPath) {
        //
    }
}
