//
//  Copyright © 2023 Draftz. All rights reserved.
//

import UIKit

public typealias CollectionViewCellAttributes = CollectionViewItemAttributes
public typealias CollectionViewItem = CollectionViewCellItem

public struct CollectionViewItemAttributes {
    public var indexPath: IndexPath = .init()

    public init() {
        //
    }
}

public protocol CollectionViewCellItem: AnyObject {
    associatedtype Cell: CollectionViewCell

    var viewModel: Cell.ViewModel { get }
    var attributes: CollectionViewItemAttributes { get set }
    var contextActions: [UIAction] { get }

    var selectionHandler: ((Self) -> Void)? { get set }
    var deselectionHandler: ((Self) -> Void)? { get set }

    func configure(_ cell: Cell, in collectionView: UICollectionView, indexPath: IndexPath)

    func willDisplay(_ cell: Cell, in collectionView: UICollectionView, indexPath: IndexPath)
    func didEndDisplay(_ cell: Cell, in collectionView: UICollectionView, indexPath: IndexPath)
}

extension CollectionViewCellItem {
    public func matches(_ rhs: any CollectionViewCellItem) -> Bool {
        return viewModel == (rhs.viewModel as? Cell.ViewModel)
    }

    static func registerCell(in collectionView: UICollectionView) {
        Cell.register(in: collectionView, withIdentifier: "\(Cell.self)")
    }

    public func size(in collectionView: UICollectionView,
                     at indexPath: IndexPath) -> CGSize {
        return Cell.size(with: viewModel, fitting: collectionView.bounds.size, insets: collectionView.contentInset)
    }

    public func dequeueCell(in collectionView: UICollectionView, indexPath: IndexPath) -> Cell? {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(Cell.self)",
                                                            for: indexPath) as? Cell else {
            return nil
        }

        attributes.indexPath = indexPath
        configure(cell, in: collectionView, indexPath: indexPath)
        return cell
    }

    public func configure(in collectionView: UICollectionView, indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? Cell else {
            return
        }

        configure(cell, in: collectionView, indexPath: indexPath)
    }

    public func willDisplay(_ cell: UICollectionViewCell, in collectionView: UICollectionView, indexPath: IndexPath) {
        guard let cell = cell as? Cell else {
            return
        }
        
        willDisplay(cell, in: collectionView, indexPath: indexPath)
    }

    public func willDisplay(_ cell: Cell, in collectionView: UICollectionView, indexPath: IndexPath) {}

    public func didEndDisplay(_ cell: UICollectionViewCell, in collectionView: UICollectionView, indexPath: IndexPath) {
        guard let cell = cell as? Cell else {
            return
        }

        didEndDisplay(cell, in: collectionView, indexPath: indexPath)
    }

    public func didEndDisplay(_ cell: Cell, in collectionView: UICollectionView, indexPath: IndexPath) {}

    public func cast(_ cell: UICollectionViewCell) -> Cell? {
        return cell as? Cell
    }

    func handleCellSelection() {
        selectionHandler?(self)
    }

    func handleCellDeselection() {
        deselectionHandler?(self)
    }
}

// MARK: - BasicCollectionViewItem

open class BasicCollectionViewItem<Cell: CollectionViewCell>: CollectionViewCellItem {
    public let viewModel: Cell.ViewModel
    public var attributes: CollectionViewItemAttributes = .init()
    public var contextActions: [UIAction] = []

    public var selectionHandler: ((BasicCollectionViewItem) -> Void)?
    public var deselectionHandler: ((BasicCollectionViewItem) -> Void)?

    public init(viewModel: Cell.ViewModel) {
        self.viewModel = viewModel
    }

    open func configure(_ cell: Cell, in collectionView: UICollectionView, indexPath: IndexPath) {
        cell.update(with: viewModel, attributes: attributes)
    }

    open func willDisplay(_ cell: Cell, in collectionView: UICollectionView, indexPath: IndexPath) {
        //
    }

    open func didEndDisplay(_ cell: Cell, in collectionView: UICollectionView, indexPath: IndexPath) {
        //
    }
}
